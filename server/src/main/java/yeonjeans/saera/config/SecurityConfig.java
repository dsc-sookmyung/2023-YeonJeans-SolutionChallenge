package yeonjeans.saera.config;

import lombok.AllArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import yeonjeans.saera.exception.CustomAuthenticationEntryPoint;
import yeonjeans.saera.exception.ExceptionHandlerFilter;
import yeonjeans.saera.security.jwt.JwtAuthenticationFilter;
import yeonjeans.saera.security.jwt.TokenProvider;
import yeonjeans.saera.util.LoggingFilter;

@AllArgsConstructor
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    private final TokenProvider tokenProvider;
    private final CustomAuthenticationEntryPoint customAuthenticationEntryPoint;
    private final ExceptionHandlerFilter exceptionHandlerFilter;
    private final LoggingFilter loggingFilter;

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter(){
        return new JwtAuthenticationFilter(tokenProvider);
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> web.ignoring().antMatchers(
                "/v3/api-docs/**", "/h2-console/**"
        );
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//        http
//                .exceptionHandling()
//                .authenticationEntryPoint(customAuthenticationEntryPoint);
//        http.formLogin();
//        http.oauth2Login();
        http.csrf().disable();
        http.sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);

        http
                .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
                .addFilterBefore(exceptionHandlerFilter, JwtAuthenticationFilter.class)
                .addFilterBefore(loggingFilter, exceptionHandlerFilter.getClass());

        http.authorizeRequests()
                .antMatchers("/top5-statement", "/reissue-token", "/word-id", "/words/record/**", "/statements/record/**", "/today-list", "/auth/**").permitAll()
                .antMatchers( "/swagger-ui/*").permitAll()
                .anyRequest().authenticated();

        return http.build();
    }
}
