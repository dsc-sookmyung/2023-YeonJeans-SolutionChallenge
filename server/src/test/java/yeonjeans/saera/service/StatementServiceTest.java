package yeonjeans.saera.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.example.StatementRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.dto.ListItemDto;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@SpringBootTest
public class StatementServiceTest {
    @Autowired
    StatementRepository statementRepository;
    @Autowired
    MemberRepository memberRepository;
    @Autowired
    WebClient webClient;
    @Autowired
    String MLserverBaseUrl;
    @Value("${ml.secret}")
    private String ML_SECRET;

    @Transactional
    @Test
    public void searchByContentAsync() {
        List<Long> recommendIdList = new ArrayList<>();
        String keyword = "아메리카노";
        Member member = memberRepository.findById(1L).get();

        Mono<String> monoResponse = webClient.get()
                .uri(MLserverBaseUrl+"/semantic-search?query=아메리카노")
                .header("access-token", ML_SECRET)
                .retrieve()
                .bodyToMono(String.class);

        List<ListItemDto> list1 = statementRepository.findAllByContentContaining(member, "%아메리카노%")
                .stream().map(ListItemDto::new).collect(Collectors.toList());

        String response = monoResponse.block();
        recommendIdList.add(new JSONObject(response).getJSONObject("0").getLong("id"));
        recommendIdList.add(new JSONObject(response).getJSONObject("1").getLong("id"));
        recommendIdList.add(new JSONObject(response).getJSONObject("2").getLong("id"));

        List<ListItemDto> list2 = statementRepository.findAllByIdWithBookmarkAndPractice(member, recommendIdList)
                .stream().map(item -> new ListItemDto(item, true)).collect(Collectors.toList());

        System.out.println(list1);
        System.out.println(list2);
        System.out.println(new JSONArray().put(list1).put(list2));

    }
}
