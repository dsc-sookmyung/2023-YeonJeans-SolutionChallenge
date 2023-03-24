package yeonjeans.saera.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StreamUtils;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.custom.CTag;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.custom.CustomCtag;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.BookmarkRepository;
import yeonjeans.saera.domain.repository.PracticeRepository;
import yeonjeans.saera.domain.repository.custom.CTagRepository;
import yeonjeans.saera.domain.repository.custom.CustomCTagRepository;
import yeonjeans.saera.domain.repository.custom.CustomRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.dto.ListItemDto;
import yeonjeans.saera.dto.NameIdDto;
import yeonjeans.saera.dto.CustomResponseDto;
import yeonjeans.saera.dto.ML.PitchGraphDto;
import yeonjeans.saera.exception.CustomException;
import yeonjeans.saera.exception.ErrorCode;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static yeonjeans.saera.domain.entity.example.ReferenceType.CUSTOM;
import static yeonjeans.saera.exception.ErrorCode.CUSTOM_NOT_FOUND;

@RequiredArgsConstructor
@Service
public class CustomServiceImpl {
    private final CustomRepository customRepository;
    private final CTagRepository cTagRepository;
    private final CustomCTagRepository customCTagRepository;
    private final MemberRepository memberRepository;
    private final PracticeRepository practiceRepository;
    private final BookmarkRepository bookmarkRepository;

    private final WebClient webClient;
    private final String MLserverBaseUrl;
    @Value("${ml.secret}")
    private String ML_SECRET;
    @Value("${clova.client-id}")
    private String CLOVA_ID;
    @Value("${clova.client-secret}")
    private String CLOVA_SECRET;

    @Transactional
    public CustomResponseDto create(String content, ArrayList<String> tags, Long memberId){
        Member member = memberRepository.findById(memberId)
                .orElseThrow(()->new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        byte[] audioBytes = getTTS(content);
        ByteArrayResource audioResource = new ByteArrayResource(audioBytes) {
            @Override
            public String getFilename() {
                return "audio.wav";
            }
        };
        PitchGraphDto graphDto = getPitchGraph(audioResource);

        Custom custom = Custom.builder()
                .content(content)
                .file(audioBytes)
                .pitchX(graphDto.getPitch_x().toString())
                .pitchY(graphDto.getPitch_y().toString())
                .member(member)
                .build();

        List<CTag> tagList = tags.stream().map(ctag->saveTag(ctag, member)).collect(Collectors.toList());

        List<CustomCtag> relrationList = tagList.stream().map(cTag -> new CustomCtag(custom, cTag)).collect(Collectors.toList());
        customCTagRepository.saveAll(relrationList);

        return new CustomResponseDto(customRepository.save(custom));
    }

    @Transactional
    public void delete(Long fk, Long memberId) {
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Custom custom = customRepository.findById(fk).orElseThrow(()-> new CustomException(ErrorCode.CUSTOM_NOT_FOUND));

        List<CustomCtag> ctList = customCTagRepository.findAllByCustom(custom);
        customCTagRepository.deleteAll(ctList);

        //member가 만들었고, CustomCtag에 연관관계가 없는 tag
        List<CTag> tList = cTagRepository.findAllByMemberNotInCustomCTag(member);
        cTagRepository.deleteAll(tList);

        customRepository.delete(custom);

        Practice practice = practiceRepository.findByMemberAndTypeAndFk(member, CUSTOM, fk).orElse(null);
        Bookmark bookmark = bookmarkRepository.findByMemberAndTypeAndFk(member, CUSTOM, fk).orElse(null);
        if(practice != null) practiceRepository.delete(practice);
        if(bookmark != null) bookmarkRepository.delete(bookmark);
    }

    public List<NameIdDto> getTagList(Long memberId) {
        List<CTag> cTagList = cTagRepository.findAllByMemberId(memberId);
        return cTagList.stream().map(NameIdDto::new).collect(Collectors.toList());
    }

    public CustomResponseDto read(Long id, Long memberId) {
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<Object[]> list = customRepository.findByIdWithBookmarkAndPractice(member, id);
        if(list.isEmpty()) throw new CustomException(CUSTOM_NOT_FOUND);
        Object[] result = list.get(0);

        Custom custom = result[0] instanceof Custom ? ((Custom) result[0]) : null;
        Bookmark bookmark = result[1] instanceof Bookmark ? ((Bookmark) result[1]) : null;
        Practice practice = result[2] instanceof Practice ? ((Practice) result[2]) : null;

        return new CustomResponseDto(custom, bookmark, practice);
    }

    private CTag saveTag(String tagname, Member member){
        Optional<CTag> cTag = cTagRepository.findByMemberAndName(member, tagname);
        if(cTag.isPresent())
            return cTag.get();
        return cTagRepository.save(new CTag(tagname, member));
    }

    private PitchGraphDto getPitchGraph(Resource resource){
        PitchGraphDto graphDto = webClient.post()
                .uri(MLserverBaseUrl + "pitch-graph")
                .header("access-token", ML_SECRET)
                .body(BodyInserters.fromMultipartData("audio", resource))
                .retrieve()
                .onStatus(HttpStatus::isError, response -> {
                    if(response.statusCode() == HttpStatus.UNPROCESSABLE_ENTITY)
                        throw new CustomException(ErrorCode.UNPROCESSABLE_ENTITY);
                    throw new CustomException(ErrorCode.COMMUNICATION_FAILURE);
                })
                .bodyToMono(PitchGraphDto.class)
                .block();
        return graphDto;
    }

    private byte[] getTTS(String content){
        Resource resource = webClient.post()
                .uri("https://naveropenapi.apigw.ntruss.com/tts-premium/v1/tts")
                .headers(headers -> {
                    headers.set("Content-Type", "application/x-www-form-urlencoded");
                    headers.set("X-NCP-APIGW-API-KEY-ID", CLOVA_ID);
                    headers.set("X-NCP-APIGW-API-KEY", CLOVA_SECRET);
                })
                .body(BodyInserters.fromFormData
                                ("speaker", "vhyeri")
                        .with("text", content)
                        .with("format", "wav"))
                .retrieve()
                .onStatus(HttpStatus::isError, response -> {
                    if(response.statusCode() == HttpStatus.BAD_REQUEST)
                        System.out.println("\n\n[in getTTSfromClova to create Custom] BAD_REQUEST\n\n");
                    throw new CustomException(ErrorCode.COMMUNICATION_FAILURE);
                })
                .bodyToMono(Resource.class)
                .block();

        byte[] audioBytes = new byte[0];
        try {
            InputStream inputStream = resource.getInputStream();
            audioBytes = StreamUtils.copyToByteArray(inputStream);
            inputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return audioBytes;
    }

    public List<ListItemDto> getCustoms(boolean bookmarked, String content, ArrayList<String> tags, Long memberId) {
    Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Stream<Object[]> stream;
        if(bookmarked){
            stream = customRepository.findBookmarkedAllAndPractice(member).stream();
        }
        else if(content==null&&tags==null){
            stream = customRepository.findAllWithBookmarkAndPractice(member).stream();
        }else if(content!=null&&tags!=null){
            stream = Stream.concat(customRepository.findAllByContentContaining(member,'%'+content+'%').stream(), searchByTagList(tags, member)).distinct();
        }else if(content!=null){
            stream = customRepository.findAllByContentContaining(member,'%'+content+'%').stream();
        }else{
            stream = searchByTagList(tags, member);
        }
        return stream.map(ListItemDto::new).collect(Collectors.toList());
    }

    private Stream<Object[]> searchByTagList(ArrayList<String> tags, Member member) {
        List<Long> idList = customRepository.findAllByTagnameIn(tags);
        return customRepository.findAllByIdWithBookmarkAndPractice(member, idList).stream();
    }

    public Resource getExampleRecord(Long id) {
        Custom custom = customRepository.findById(id).orElseThrow(()->new CustomException(CUSTOM_NOT_FOUND));
        return new ByteArrayResource(custom.getFile()) {
            @Override
            public String getFilename() {
                return "audio.wav";
            }
        };
    }
}