package yeonjeans.saera.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class AppConfig {

    @Bean
    public String MLserverBaseUrl(){
        return "http://34.64.207.59/";
    }

    @Bean
    public WebClient webClient() {
        return WebClient.create();
    }
}
