package yeonjeans.saera.security.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import yeonjeans.saera.dto.TokenResponseDto;
import yeonjeans.saera.exception.CustomException;
import yeonjeans.saera.exception.ErrorCode;
import yeonjeans.saera.security.service.CustomUserDetailService;

import java.security.Key;
import java.util.*;

@Slf4j
@Component
public class TokenProvider {
    private final long accessTokenExpiration = 60 * 60 * 1000L; //1hour
    private final long refreshTokenExpiration = 60 * 60 * 24 * 14 * 1000L; //2weeks
    private final Key key;

    private final CustomUserDetailService userDetailService;

    public TokenProvider(@Value("${jwt.secret}") String secretKey, CustomUserDetailService userDetailService) {
        this.userDetailService = userDetailService;
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }

    public TokenResponseDto generateToken(Long memberId, String nickname) {
        Date now = new Date();
        Map<String , String> map = new HashMap<>();
        map.put("id", String.valueOf(memberId));
        map.put("name", nickname);

        String accessToken = Jwts.builder()
                .setClaims(map)
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + accessTokenExpiration))
                .signWith(key)
                .compact();

        String refreshToken = Jwts.builder()
                .setSubject(String.valueOf(memberId))
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime()+ refreshTokenExpiration))
                .signWith(key)
                .compact();

        return TokenResponseDto.builder()
                .grantType("Bearer")
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public String getMemberId(String accessToken){
        Claims claims = parseClaims(accessToken);
        return claims.get("id", String.class);
    }

    public String getSubject(String token){
        Claims claims = parseClaims(token);
        return claims.getSubject();
    }

    private Claims parseClaims(String token) throws JwtException, IllegalArgumentException {
        try {
            return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
        }catch(MalformedJwtException e) {
            log.error("[in parseClaims] token: {} ", token);
            throw e;
        }
    }

    public boolean validateToken(String token){
        try{
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
        }catch (ExpiredJwtException expiredJwtException){
            throw new CustomException(ErrorCode.EXPIRED_TOKEN);
        }catch (Exception e){
            log.error("[in validateToken] refreshToken: {}", token);
            throw new CustomException(ErrorCode.WRONG_TOKEN);
        }
        return true;
    }

    public Authentication getAuthentication(String token) {
        UserDetails userDetails = userDetailService.loadUserByUsername(this.getMemberId(token));
        return new UsernamePasswordAuthenticationToken(userDetails, "", userDetails.getAuthorities());
    }
}