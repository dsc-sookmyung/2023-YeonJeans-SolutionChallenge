package yeonjeans.saera.security.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import yeonjeans.saera.domain.entity.member.Platform;
import yeonjeans.saera.dto.oauth.GoogleUser;

@Service
@RequiredArgsConstructor
public class OAuthService {
    private final GoogleOAuth googleOauth;

    public GoogleUser getUserInfo(Platform platform, String code){
        switch (platform){
            case GOOGLE:{
                return googleOauth.getUserInfo(code);
            }
            case APPLE:{

            }
            default: {
                throw new IllegalArgumentException("알 수 없는 소셜 로그인 타입입니다.");
            }
        }
    }
}
