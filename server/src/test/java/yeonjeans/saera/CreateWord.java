package yeonjeans.saera;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.springframework.test.annotation.Commit;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StreamUtils;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import yeonjeans.saera.domain.entity.example.Word;
import yeonjeans.saera.domain.repository.example.TagRepository;
import yeonjeans.saera.domain.repository.example.WordRepository;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@SpringBootTest
public class CreateWord {
    @Autowired
    private WordRepository wordRepository;
    @Autowired
    private TagRepository tagRepo;

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
    public void creatData(){
        String[] notationArray = {
                "굳이", "역사", "여자", "아주머니", "같이",
                "맏이", "기적", "일요일", "월요일", "활용하다",

                "이발소", "예의", "이용하다", "따로", "낭비",
                "며칠", "관심", "뮤지컬", "마을", "얼마나",

                "공부", "교회", "신용카드", "그런데", "음악"
        };//25

        String[] notationArray2 = {
            "붙이다", "닫히다", "양심", "요리", "이유",
                "래일", "예절", "그리다", "독려", "베갯잇",
                "나랏일", "혜택", "깻잎", "시장"
        };//39

        List<Word> wordList = Arrays.stream(notationArray2).map(this::makeWord).collect(Collectors.toList());
        wordRepository.saveAll(wordList);
    }

    @Test
    public Word makeWord(String notation) {
        Resource resource = webClient.post()
                .uri("https://naveropenapi.apigw.ntruss.com/tts-premium/v1/tts")
                .headers(headers -> {
                    headers.set("Content-Type", "application/x-www-form-urlencoded");
                    headers.set("X-NCP-APIGW-API-KEY-ID", CLOVA_ID);
                    headers.set("X-NCP-APIGW-API-KEY", CLOVA_SECRET);
                })
                .body(BodyInserters.fromFormData
                                ("speaker", "vhyeri")
                        .with("text", notation)
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

        Word result = Word.builder()
                .file(audioBytes)
                .definition("")
                .notation(notation)
                .pronunciation("")
                .build();

        return result;
    }
}
