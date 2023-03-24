package yeonjeans.saera.security.dto;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;

import java.util.Collection;

@Getter
public class AuthMember extends User {
    private String email;
    private String name;
    private Long id;

    public AuthMember(String email, String password, Collection<? extends GrantedAuthority> authorities, Long id, String name){
        super(email, password, authorities);
        this.email = email;
        this.name = name;
        this.id = id;
    }
}
