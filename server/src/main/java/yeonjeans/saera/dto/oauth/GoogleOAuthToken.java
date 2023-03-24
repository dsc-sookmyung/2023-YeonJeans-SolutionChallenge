package yeonjeans.saera.dto.oauth;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

//구글에 일회성 코드를 다시 보내 받아올 액세스 토큰을 포함한 JSON 문자열을 담을 클래스
@Builder
@AllArgsConstructor
@Getter
@Setter
public class GoogleOAuthToken {
    private String access_token;
    private String refresh_token;
    private int expires_in;
    private String scope;
    private String token_type;
    private String id_token;
}
