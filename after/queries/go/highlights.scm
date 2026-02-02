; Increase priority to 130 to ensure strings win over LSP semantic tokens (priority 125)
; This keeps import "fmt" as a string while fmt.Println uses semantic tokens
((interpreted_string_literal) @string (#set! "priority" 130))
((raw_string_literal) @string (#set! "priority" 130))
((interpreted_string_literal_content) @string (#set! "priority" 130))
((raw_string_literal_content) @string (#set! "priority" 130))
