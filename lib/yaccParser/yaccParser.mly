%token TYPE KIND LAMBDA PRODUCT APP TERMWITHYPEANNO LET LEMMA EQUAL IN ARROW TYPE_ARROW
%token<string> VAR HOLE
%token BR_OPN BR_CLS
%token ASTERISK COMMA COLON IN EQUAL
%token EOF

%type<ParserAst.program> program
%start program


%{

open ParserAst

let current_pos () =
  let start_p = symbol_start_pos () in
  let end_p   = symbol_end_pos () in
  { start  = start_p
  ; length = end_p.pos_cnum - start_p.pos_cnum
  }

let make data =
  { pos  = current_pos ()
  ; data = data
  }

%}

%%

expression
: TYPE { make (Type) }
| KIND { make (Kind) }
| VAR  { make (Var $1) }
| HOLE { make (Hole $1) }
| LET VAR EQUAL expression IN expression {make (Let ($2, $4, $6)) }
| LEMMA VAR EQUAL expression IN expression { make (Lemma ($2, $4, $6)) }
| LAMBDA VAR COLON expression ARROW expression {make  (Lambda ($2, (Some $4), $6)) }
| LAMBDA VAR ARROW expression {make (Lambda ($2, None, $4)) }
| PRODUCT VAR COLON expression ARROW expression {make (Product ($2, $4, $6)) }
| expression COLON expression {make (TermWithTypeAnno ($1, $3)) }
| expression TYPE_ARROW expression {make (TypeArrow ($1, $3)) }
| BR_OPN expression BR_CLS { $2 }
| expression expression { make (App ($1, $2)) }

expression_definition
: LET VAR EQUAL expression IN expression {make (Let ($2, $4, $6)) }
| LEMMA VAR EQUAL expression IN expression { make (Lemma ($2, $4, $6)) }
| LET VAR EQUAL expression {make (LetDef ($2, $4)) }
| LEMMA VAR EQUAL expression { make (LemmaDef ($2, $4)) }
;

/* ========================================================================= */

expression_list_rev
: /* empty */            { []       }
| expression_list_rev expression_definition { $2 :: $1 }
;

expression_list
: expression_list_rev { List.rev $1 }
;

/* ========================================================================= */

program
: expression_list EOF { $1 }
;

%%