package yeonjeans.saera.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import yeonjeans.saera.Service.BookmarkServiceImpl;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.exception.ErrorResponse;
import yeonjeans.saera.security.dto.AuthMember;

@RequiredArgsConstructor
@RestController
public class BookmarkController {

    private final BookmarkServiceImpl bookmarkService;

    @Operation(summary = "즐겨찾기 생성", description = "type과 id를 사용하여 즐겨찾기 생성", tags = { "Bookmark Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "요청 성공"),
                    @ApiResponse(responseCode = "409", description = "중복된 즐겨찾기 요청", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @PostMapping("/bookmark")
    public ResponseEntity<?> createBookmark(@RequestParam(value = "type", required = true)ReferenceType type,
                                            @RequestParam(value = "fk", required = true) Long fk,
                                            @RequestHeader String Authorization) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        bookmarkService.create(type, fk, principal.getId());
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "즐겨찾기 삭제", description = "type과 id를 사용하여 Bookmark를 삭제합니다.", tags = { "Bookmark Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "삭제 성공"),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            }
    )
    @DeleteMapping("/bookmark")
    public ResponseEntity<?> deleteBookmark(@RequestParam(value = "type", required = true)ReferenceType type,
                                            @RequestParam(value = "fk", required = true) Long fk,
                                            @RequestHeader String Authorization) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        bookmarkService.delete(type, fk, principal.getId());
        return ResponseEntity.ok().build();
    }
}