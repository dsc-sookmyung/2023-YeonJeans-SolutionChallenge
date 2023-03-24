package yeonjeans.saera.security.service;

import org.springframework.http.ResponseEntity;
import yeonjeans.saera.dto.oauth.GoogleUser;

public interface SocialOAuth {
    public GoogleUser getUserInfo(String code);
    
}
