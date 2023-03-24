package yeonjeans.saera.exception;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Slf4j
@Component
public class ExceptionHandlerFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        try{
            filterChain.doFilter(request,response);
        } catch (ExpiredJwtException e) {
            log.error(e.toString());
            setErrorResponse(response, ErrorCode.EXPIRED_TOKEN);
        } catch (JwtException e) {
            log.error(e.toString());
            setErrorResponse(response, ErrorCode.WRONG_TOKEN);
        } catch (CustomException e){
            setErrorResponse(response, e.getErrorCode());
        }
    }

    public void setErrorResponse(HttpServletResponse response, ErrorCode errorCode) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        JSONObject responseJson = new JSONObject();
        if(errorCode == ErrorCode.EXPIRED_TOKEN) responseJson.put("status", 499);
        else responseJson.put("status", errorCode.getHttpStatus().value());
        responseJson.put("error", errorCode.getHttpStatus().name());
        responseJson.put("code", errorCode.name());
        responseJson.put("message", errorCode.getDetail());

        //한글 출력을 위해 getWriter() 사용
        response.getWriter().print(responseJson);
    }
}