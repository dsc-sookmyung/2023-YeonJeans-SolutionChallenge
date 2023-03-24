package yeonjeans.saera;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.test.annotation.Commit;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StreamUtils;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.domain.entity.example.StatementTag;
import yeonjeans.saera.domain.entity.example.Tag;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.entity.member.MemberRole;
import yeonjeans.saera.domain.entity.member.Platform;
import yeonjeans.saera.domain.repository.BookmarkRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.domain.repository.example.StatementRepository;
import yeonjeans.saera.domain.repository.example.StatementTagRepository;
import yeonjeans.saera.domain.repository.example.TagRepository;
import yeonjeans.saera.dto.ML.PitchGraphDto;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@SpringBootTest
public class CreateStatement {
    @Autowired
    private MemberRepository memberRepo;
    @Autowired
    private BookmarkRepository bookmarkRepo;
    @Autowired
    private StatementRepository statementRepo;
    @Autowired
    private TagRepository tagRepo;
    @Autowired
    private StatementTagRepository statementTagRepo;
    @Autowired
    private WebClient webClient;
    @Autowired
    private String MLserverBaseUrl;
    @Value("${ml.secret}")
    private String ML_SECRET;
    @Value("${clova.client-id}")
    private String CLOVA_ID;
    @Value("${clova.client-secret}")
    private String CLOVA_SECRET;

    @Transactional
    @Test
    public void createDummy(){
        String[] contentArray = {
                "화장실은 어디에 있나요?", "신분증은 안 가져왔는데요.", "본인인데도 안 되나요?", "괜찮습니다.", "안녕하세요?",
                "이건 얼마예요?", "언제 한 번 놀러 오세요.", "공연 보러 가자.", "넌 좋아하는 게 뭐야?",  "넌 쉬는 날이 언제야?",

                "신용카드 발급하려고 하는데요.", "이제 괜찮아졌습니다.", "많이 아프세요?", "몰랐어요.", "다시 말씀해 주실래요?",
                "예약 취소하려고요.", "어떻게 할까요?", "여기로 오시겠어요?", "좋습니다.", "이게 끝이에요.",

                "죄송합니다.", "사용하는 언어가 달라서 모르겠습니다.", "물어본다는 게 깜빡했어요.", "밥이나 먹자.", "저 운전면허 있어요.",
                "주민등록증 새로 발급 받으려고요.", "아이스 아메리카노 하나 주세요.", "우유 대신 두유로 바꿀 수 있나요?", "현금 결제도 되나요?", "이건 뭐예요?",

                "제가 커피는 잘 못 마셔요.", "매운 음식은 잘 못 먹어요.", "커피 마시러 가실래요?", "실례합니다.", "가까운 병원으로 가주세요.",
                "천천히 말씀해 주세요.", "어디 출신이세요?", "삼겹살 4인분 주세요.", "소주 한 병 주세요.", "몇시에 문 닫아요?",

                "여기서 먹고 갈게요.", "테이크 아웃이요.", "포장해 주세요.", "와이파이 비밀번호가 뭔가요?", "콘센트 어디에 있어요?",
                "영수증은 버려 주세요.", "봉투에 넣어주세요.", "적립은 안 해요.", "이거 환불하려고요.", "이거 교환하려고요.",

                "일시불로 결제해 주세요.", "다 해서 얼마예요?", "비밀번호를 재발급 받고 싶어요.", "공인인증서 발급하고 싶어요.", "체크카드 만들려고 하는데요.",
                "오이 알레르기가 있어요.", "근처에 약국은 어디에 있나요?", "타이레놀 있나요?", "여기서 세워 주세요.", "맛있게 드세요.",

                "새해 복 많이 받으세요!", "즐거운 추석 보내세요.", "메리 크리스마스!", "휴대폰 충전해 주세요.", "술은 잘 못 마셔요.",
                "수돗물이 안 나와요.", "따뜻한 물이 안 나와요.", "옆집이 너무 시끄러워요.", "변기가 막혔어요.", "보일러가 고장났어요.",

                "지하철역에서 얼마나 걸려요?", "이 버스는 어디로 가나요?", "여기 와이파이 되나요?", "먹고 싶은 음식이 있나요?", "편안한 밤 되시길 바래요.",
                "만나서 반갑습니다.", "아무것도 아닙니다.", "감사합니다.", "나중에 봬요.", "조금만 깎아주세요.",

                "메세지 남겨 드릴까요?", "여기에서 1km 정도 떨어져있어요.", "휴대폰을 잠시 빌릴 수 있을까요?", "MBTI가 뭐예요?", "진통제 주세요.",
                "해열제 주세요.", "지금 몇 시에요?", "추천하는 메뉴가 있나요?", "버스를 놓쳐서 늦었어요.", "거기서 거기에요.",

                "지금 집에 가야해서요.", "노래 추천해주세요.", "뜨거우니까 조심하세요.", "영수증 드릴까요?", "내일까지 해 볼게요.",
                "내일로 미룰 수 있을까요?", "이따가 미팅 있어요.", "조금만 더 주세요.", "아무거나 다 좋아.", "저는 상관 없어요.",
        };

        String[] contentArray2 = {
                "그거 좋은 것 같아.", "그건 좀 별로야.", "마음에 안 들어.", "잇몸이 아파요.", "치과 검진 하러 왔어요.",
                "영화는 무슨 장르에요?", "세관 서류 필요해요?", "길을 잃어버렸어요.", "지금 체크아웃하고 싶어요.", "버스 요금은 얼마인가요?",

                "연세를 여쭤보아도 될까요?", "당근은 빼주세요.", "이번 주말에 캠핑갈래요?", "이번에 새로 입사한 길동입니다.", "송금 수수료는 얼마인가요?",
                "보증금은 얼마예요?", "여권을 잃어버린 것 같아요.", "계좌 이체를 하고 싶습니다.", "통장을 만들고 싶습니다.", "저축 예금 계좌를 개설하고 싶습니다.",

                "전화주신 분 성함을 알 수 있을까요?", "이따가 다시 전화해 주실 수 있으세요?", "시간내주셔서 감사합니다.", "여기 제 명함입니다.", "무슨 일로 찾으셨어요?",
                "잘 부탁드립니다.", "다음에는 제가 사겠습니다.", "다음 주에 휴가를 가도 될까요?", "내일까지 보고서를 올리겠습니다.", "오늘 막 입사했습니다.",

                "근무지가 어디인가요?", "이직을 희망하고 있습니다.", "회사에서 근무한 경험이 있나요?", "앞으로도 잘 부탁드립니다.", "별 말씀을요.",
                "어제는 너무 재밌었습니다.", "주말에 일정이 있나요?", "토요일에는 시간이 안될 것 같아요.", "회의 시간을 늦춰도 될까요?", "다음에 제가 찾아뵙겠습니다.",

                "뭐 좀 여쭤봐도 될까요?", "좀 더 큰 사이즈가 있을까요?", "할인되는 상품이 있을까요?", "저는 지금 우울해요.", "즐겨 듣는 음악이 있나요?",
                "이 박스를 같이 들어줄 수 있을까요?", "역사 책을 빌릴 수 있을까?", "진료비는 어디서 납부하면 될까요?", "어떻게 오셨어요?", "손에 화상을 입었어요.",

                "발목을 삐었어요.", "진단서를 받을 수 있을까요?", "진료 예약할 수 있을까요?", "조금만 기다려 주시겠어요?", "미안합니다.",
                "바람이 시원하다.", "전화번호가 어떻게 되나요?", "주민등록등본 떼러 왔는데요.", "주말 잘 보내고 월요일에 만납시다.", "먼저 들어가보겠습니다.",

                "안 먹겠습니다.", "언제 배송이 시작되나요?", "언제까지 물품을 받아볼 수 있나요?", "너는 어떻게 생각해?", "오늘도 화이팅합시다.", "제가 해보겠습니다.",
                "환절기 감기 조심하세요."
        };

        List<Statement> statementList = Arrays.stream(contentArray2).map(this::makeStatement).collect(Collectors.toList());
        statementRepo.saveAll(statementList);
//
//        String[] tagNameArray1 = {"일상", "은행/공공기관", "소비", "회사", "인사"}; //0 1 2 3 4
//        String[] tagNameArray2 = {"의문문", "존댓말", "부정문", "감정표현"}; //0 1 2 3
//        String[] tagNameArray3 = {"구개음화", "두음법칙", "치조마찰음화", "ㄴ첨가", "ㄹ첨가", "여→애", "단모음화", "으→우", "어→오", "오→어", "모음조화"};
//
//        List<Tag> tagList1 = Arrays.stream(tagNameArray1).map(Tag::new).map(tag->tagRepo.save(tag)).collect(Collectors.toList());
//        List<Tag> tagList2 = Arrays.stream(tagNameArray2).map(Tag::new).map(tag->tagRepo.save(tag)).collect(Collectors.toList());
//        List<Tag> tagList3 = Arrays.stream(tagNameArray3).map(Tag::new).map(tag->tagRepo.save(tag)).collect(Collectors.toList());

    }

    @Test
    public Statement makeStatement(String content) {
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
                .bodyToMono(Resource.class)
                .block();

        byte[] audioBytes = new byte[0];
        try {
            audioBytes = StreamUtils.copyToByteArray(resource.getInputStream());
        } catch (IOException e) {
            e.printStackTrace();
        }

        ByteArrayResource audioResource = new ByteArrayResource(audioBytes) {
            @Override
            public String getFilename() {
                return "audio.wav";
            }
        };

        PitchGraphDto graphDto = webClient.post()
                .uri(MLserverBaseUrl + "pitch-graph")
                .header("access-token",ML_SECRET)
                .body(BodyInserters.fromMultipartData("audio", audioResource))
                .retrieve()
                .onStatus(HttpStatus::is4xxClientError, response -> {
                    System.err.println("Client error: "+ response.statusCode());
                    return response.bodyToMono(String.class)
                            .flatMap(body -> {
                                System.err.println("Response body: " + body);
                                return Mono.error(new RuntimeException("Client error"));
                            });
                })
                .onStatus(HttpStatus::is5xxServerError, response -> {
                    System.err.println("Server error: "+ response.statusCode());
                    return response.bodyToMono(String.class)
                            .flatMap(body -> {
                                System.err.println("Response body: {}"+ body);
                                return Mono.error(new RuntimeException("Server error"));
                            });
                })
                .bodyToMono(PitchGraphDto.class)
                .block();

        Statement result = Statement.builder()
                .content(content)
                .file(audioBytes)
                .pitchX(graphDto.getPitch_x().toString())
                .pitchY(graphDto.getPitch_y().toString())
                .build();

        return result;
    }
}
