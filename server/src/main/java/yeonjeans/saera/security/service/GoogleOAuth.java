package yeonjeans.saera.security.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;
import yeonjeans.saera.dto.oauth.GoogleOAuthToken;
import yeonjeans.saera.dto.oauth.GoogleUser;
import yeonjeans.saera.exception.CustomException;
import yeonjeans.saera.exception.ErrorCode;

import java.util.HashMap;
import java.util.Map;

@Log4j2
@Component
@RequiredArgsConstructor
public class GoogleOAuth implements SocialOAuth {
    @Value("${social.google.url}")
    private String GOOGLE_BASE_URL;
    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String GOOGLE_CLIENT_ID;
    @Value("${spring.security.oauth2.client.registration.google.redirect-uri}")
    private String GOOGLE_CALLBACK_URI;
    @Value("${spring.security.oauth2.client.registration.google.client-secret}")
    private String GOOGLE_CLIENT_SECRET;

    private final WebClient webClient;

    RestTemplate restTemplate = new RestTemplate();

    @Override
    public GoogleUser getUserInfo(String code) {
        GoogleUser userInfo;
        try{
            ResponseEntity<String> response = requestAccessToken(code);
            GoogleOAuthToken googleOAuthToken = parseAccessToken(response);
            userInfo = requestUserInfo(googleOAuthToken);
        } catch (Exception e){
            throw new CustomException(ErrorCode.GOOGLE_AUTH_ERROR);
        }
        return userInfo;
    }

    public ResponseEntity<String> requestAccessToken(String code) {
        Map<String, Object> params = new HashMap<>();
        params.put("code", code);
        params.put("client_id", GOOGLE_CLIENT_ID);
        params.put("client_secret", GOOGLE_CLIENT_SECRET);
        params.put("redirect_uri", GOOGLE_CALLBACK_URI);
        params.put("grant_type", "authorization_code");
        params.put("access_type", "offline");

        String GOOGLE_TOKEN_BASE_URL = "https://oauth2.googleapis.com/token";
        ResponseEntity<String> responseEntity =
                restTemplate.postForEntity(GOOGLE_TOKEN_BASE_URL, params, String.class);

        if (responseEntity.getStatusCode() == HttpStatus.OK) {
            return responseEntity;
        }
        return null;// 구글 로그인 실패....? ^^?
    }

    public GoogleOAuthToken parseAccessToken(ResponseEntity<String> response){
        JSONObject json = new JSONObject(response.getBody());

        GoogleOAuthToken googleOAuthToken = GoogleOAuthToken.builder()
                .access_token(json.getString("access_token"))
                .id_token(json.getString("id_token"))
                .expires_in(json.getInt("expires_in"))
                .token_type(json.getString("token_type"))
                .scope(json.getString("scope"))
                .build();

        return googleOAuthToken;
    }

    public GoogleUser requestUserInfo(GoogleOAuthToken oAuthToken) {
        String GOOGLE_USERINFO_REQUEST_URL="https://www.googleapis.com/oauth2/v1/userinfo";

        GoogleUser userInfo = webClient.get()
                .uri(GOOGLE_USERINFO_REQUEST_URL)
                .header("Authorization","Bearer " + oAuthToken.getAccess_token())
                .retrieve()
                .bodyToMono(GoogleUser.class)
                .block();
        return userInfo;
    }
}
