; extends
((interpreted_string_literal) @string (#set! "priority" 130))
((raw_string_literal) @string (#set! "priority" 130))
((interpreted_string_literal_content) @string (#set! "priority" 130))
((raw_string_literal_content) @string (#set! "priority" 130))

("return" @keyword.return (#set! "priority" 130))
("func" @keyword.function (#set! "priority" 130))

((true) @constant.builtin (#set! "priority" 130))
((false) @constant.builtin (#set! "priority" 130))
((nil) @constant.builtin (#set! "priority" 130))
((iota) @constant.builtin (#set! "priority" 130))

("map" @type.builtin (#set! "priority" 130))
("chan" @type.builtin (#set! "priority" 130))
("struct" @type.builtin (#set! "priority" 130))

