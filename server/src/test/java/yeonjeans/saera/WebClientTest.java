package yeonjeans.saera;

import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import yeonjeans.saera.dto.ML.PitchGraphDto;
import yeonjeans.saera.dto.ML.ScoreRequestDto;
import yeonjeans.saera.util.Parsing;

import java.io.IOException;

@SpringBootTest
public class WebClientTest {
    @Autowired
    WebClient webClient;
    @Autowired
    String MLserverBaseUrl;
    @Value("${ml.secret}")
    private String ML_SECRET;
    @Value("${clova.client-id}")
    private String CLOVA_ID;
    @Value("${clova.client-secret}")
    private String CLOVA_SECRET;

    @Test
    public void getRecommend() {
        String keyword = "커피";
        String response = webClient.get()
                .uri(MLserverBaseUrl+"/semantic-search?top_n=3&query="+keyword)
                .header("access-token", ML_SECRET)
                .retrieve()
                .bodyToMono(String.class)
                .block();

        System.out.println(response);
        System.out.println(new JSONObject(response).getJSONObject("0").getLong("id"));
        System.out.println(new JSONObject(response).getJSONObject("1").getLong("id"));
        System.out.println(new JSONObject(response).getJSONObject("2").getLong("id"));

        Assertions.assertNotNull(response);
    }

    @Test
    public void getPitch() throws IOException {
        Resource resource = new FileSystemResource("C:\\Users\\wndms\\Downloads\\example.wav");

        PitchGraphDto dto = webClient.post()
                .uri(MLserverBaseUrl+"pitch-graph")
                .header("access-token", ML_SECRET)
                .body(BodyInserters.fromMultipartData("audio", resource))
                .retrieve()
                .bodyToMono(PitchGraphDto.class)
                .block();

        System.out.println(dto.getPitch_x());
        System.out.println(dto.getPitch_length());
        Assertions.assertNotNull(dto.getPitch_x());
    }

    @Test
    public void getScore(){
        //given
        String array_x = "{2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 23, 24, 25, 26, 28,  29,  30,  31, 32, 34, 35, 36,  37, 38, 39, 40,  41, 44, 45, 47,  48, 49}";
        String array_y = "{0.5529897809028625, 0.5705087184906006, 0.5728230476379395,0.613701343536377, 0.6149729490280151, 0.6141186952590942, 0.6123361587524414, 0.6154983043670654, 0.6033450365066528, 0.6062413454055786, 0.6026855111122131, 0.5935204029083252, 0.56721031665802, 0.5590522289276123, 0.5474162101745605, 0.5322988033294678, 0.5096930265426636, 0.4878928065299988, 0.3608570992946625, 0.3677106499671936, 0.3790328800678253, 0.3878922462463379, 0.5482989549636841, 0.5656341314315796, 0.587600827217102, 0.5920466184616089, 0.5796314477920532, 0.4795983135700226, 0.4565112590789795, 0.43147554993629456, 0.37579724192619324, 0.3423864543437958, 0.3379935324192047, 0.33772799372673035, 0.3418845534324646, 0.4923252463340759, 0.5222675800323486, 0.5718376040458679, 0.5628867149353027, 0.5276331901550293}";
        ScoreRequestDto requestDto = new ScoreRequestDto(Parsing.stringToIntegerArray(array_x),Parsing.stringToDoubleArray(array_y),Parsing.stringToIntegerArray(array_x),Parsing.stringToDoubleArray(array_y));

        //when
        String response = webClient.post()
                .uri(MLserverBaseUrl + "score")
                .header("access-token",ML_SECRET)
                .body(BodyInserters.fromValue(requestDto))
                .retrieve()
                .bodyToMono(String.class)
                .block();

        Double dtwScore= new JSONObject(response).getDouble("DTW_score");
        Double mapeScore = new JSONObject(response).getDouble("MAPE_score");
        Assertions.assertNotNull(dtwScore);
    }

    @Test
    public void getGraphAndScoreTest(){
        Resource resource = new FileSystemResource("C:\\Users\\wndms\\Downloads\\example.wav");
        PitchGraphDto dto = webClient.post()
                .uri(MLserverBaseUrl+"pitch-graph")
                .header("access-token", ML_SECRET)
                .body(BodyInserters.fromMultipartData("audio", resource))
                .retrieve()
                .bodyToMono(PitchGraphDto.class)
                .block();

        String array_x = "{2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 23, 24, 25, 26, 28,  29,  30,  31, 32, 34, 35, 36,  37, 38, 39, 40,  41, 44, 45, 47,  48, 49}";
        String array_y = "{0.5529897809028625, 0.5705087184906006, 0.5728230476379395,0.613701343536377, 0.6149729490280151, 0.6141186952590942, 0.6123361587524414, 0.6154983043670654, 0.6033450365066528, 0.6062413454055786, 0.6026855111122131, 0.5935204029083252, 0.56721031665802, 0.5590522289276123, 0.5474162101745605, 0.5322988033294678, 0.5096930265426636, 0.4878928065299988, 0.3608570992946625, 0.3677106499671936, 0.3790328800678253, 0.3878922462463379, 0.5482989549636841, 0.5656341314315796, 0.587600827217102, 0.5920466184616089, 0.5796314477920532, 0.4795983135700226, 0.4565112590789795, 0.43147554993629456, 0.37579724192619324, 0.3423864543437958, 0.3379935324192047, 0.33772799372673035, 0.3418845534324646, 0.4923252463340759, 0.5222675800323486, 0.5718376040458679, 0.5628867149353027, 0.5276331901550293}";
        ScoreRequestDto requestDto = new ScoreRequestDto(dto.getPitch_x(), dto.getPitch_y(), Parsing.stringToIntegerArray(array_x),Parsing.stringToDoubleArray(array_y));

        //when
        String response = webClient.post()
                .uri(MLserverBaseUrl + "score")
                .header("access-token", ML_SECRET)
                .body(BodyInserters.fromValue(requestDto))
                .retrieve()
                .bodyToMono(String.class)
                .block();

        Double dtwScore= new JSONObject(response).getDouble("DTW_score");
        Double mapeScore = new JSONObject(response).getDouble("MAPE_score");
        Assertions.assertNotNull(dtwScore);
    }

    @Test
    public void getTTSfromClova() throws IOException {
        String content = "테스트 음성 어쩌구입니다.";
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

        Assertions.assertNotNull(resource);
    }
}