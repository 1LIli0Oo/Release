# Goal

* Parsing
  * Explicily declare the boundary of ambiguity resolving (e.g. on EXPR or on STAT)
  * Full CFG power, no limitation
    * Experiment: expanding all left-recursive grammer to right-recursive grammar with instructions
    * Experiment: optionally inline all rules which don't generate parser functions
  * Error message generation
  * Error recovering
* Serializing
  * Escaping and Unescaping pairs (instead of only unescaping)
  * Calculate ambiguous **ToString** cases
  * Generate **ToString** algorithm
* AST
  * Low overhead AST with reflection
  * Optional creating AST from a pool

# AST Definition (compatible with Workflow)

```
class CLASS_NAME [: BASE_CLASS]
{
  var FIELD_NAME : TYPE;
  ...
}
```

## Configurations

- Include files in generated C++ header
- Depended AST definition files
- Visitors selected to generate
- Optional reflection support
  - All AST constructors are protected
  - Generated factory class
  - If AST object pool is enabled
    - reflection is disabled
    - `Ptr<T>` for all AST types are generated will enumerated `Cast` function.
    - Use generated RTTI constructions (e.g. enum class tag for type)

## Types

- `Token`: In the previous version, `Token` is a value type, now it is a reference type.
- `CLASS-NAME`: Another class.
- `TYPE[]`: Array, whose element is not allowed to be another array.

## MISC

- Define a `ToString` algorithm with customizable configurations.

# Lexical Analyzer

- Pair name with regular expressions.
- Extendable tokens.
  - For example, recognize `R"[^\s(]\(` and invoke a callback function to determine the end of the string
- Pair a name with the token subset, and give a default name to a token full set

# Error Messages

- Generate error messages in C++ code

# Syntax Analyzer

- Priority of loops:
  - `+[ RULE ]` means if `RULE` succeeds, skipping `RULE` is not considered even if the rest doesn't parse.
  - `-[ RULE ]` means only if skipping `RULE` makes the clause not able to parse, the result of having RULE is not discarded.
  - `[ RULE ]` means keep both result
  - `+{ RULE }`, `-{ RULE }`, `{ RULE }` are similar, but `{ RULE }` may generate more than two results, meanwhile others only generate one result.
- Being able to change token subset during parsing.
- Being able to specify a error message when a certain action fails.
- Generate SAX-like parser, with a default handler to create AST.

## Supported EBNF

- TOKEN [`:` PROPERTY-NAME]
- RULE [`:` PROPERTY-NAME]
- Optional:
  - `+[` EBNF `]`
  - `-[` EBNF `]`
  - `[` EBNF `]`
- Loop:
  - `+{` EBNF `}`
  - `-{` EBNF `}`
  - `{` EBNF `}`
- `with{` PROPERTY-ASSIGNMENT ... `}`
 
## EBNF Program

- RULE {`::=` CLAUSE `as` CLASS-NAME} `;`
  - Consider a syntax here to switch token set

## ToString Algorithm Requirements
- Every clause should create an AST node. `EXP ::= '(' !EXP ')'` is not allowed, except that this clause has only one node.
- Every rule-name node should be assigned to a property. Token nodes are optional but those properties will be auto-generated.
- Loops cannot be embedded in another loop. It doesn't limit the syntax, but it limit the shape of AST.

## Development Project Structure
- Original ParserGen code will be separated from Vlpp.
- **Development Steps**
  1. Symbols for ParserGen AST
  2. Manually: symbols -> `ParserGen AST described in C++`
  3. Manually: ParserGen Syntax described in `ParserGen AST described in C++` -> `ParserGen Parser described in C++`
  4. Integrate
- **AstGen**:
  - **Goal**: given symbols and generated C++ code for AST
    - **Produce** (from unit test):
      - Generated source code (AST part): declaration, visitors, builder, reflection for ParserGen input
  - AST symbols and C++ code generation.
  - Generate visitors.
  - Generate easy builder.
  - Generate reflection.
- **Execution**:
  - **Goal**: given instructions and parse input text with SAX-like callback
  - Parser-generated instructions serialization.
  - Execute instructions as a SAX-like parser, with notification on ambiguous node, error message generation and error recovering.
- **Compiler** -> **AstGen**, **Execution**
  - **Goal**: input described using `Generated source code (AST part)` and generate instructions (text parser)
    - **Produce** (from unit test)
      - Generated C++ source code (parser part) for ParserGen input
  - Take the `ParserGen AST declaration` and generate instructions.
  - Generate the default handler to create AST for the SAX-like parser.
  - ToString algorithm.
  - Bidirection binding with AST the text.
- **ParserGen** -> **Compiler**
  - **Goal**: CLI Tool
  - Integrate `Generated source code (AST part)`
  - Integrate `Generated source code (parser part)`
  - Handle command line arguments
- **UnitTestAst**:
  - Unit test of **AstGen** building block and pool allocation etc.
  - **Produces** steps
    - Hand-written `AST for ParserGen` symbols.
    - Codegen symbols and get `Generated source code (AST part)` for ParserGen input
- **UnitTestExecution**:
  - Unit test of **Execution**.
  - Assert directly on SAX-like parser.
- **UnitTestCompiler**:
  - Unit test of **Compiler**, input are all **UnitTestExecution** test cases rewritten using the generated easy-builder for `AST for ParserGen` AST.
  - Assert on the ToString-ed AST. (shared)
  - **Produces** steps
    - Implementa ParserGen AST Input syntax using generated easy builder form `Generated source code (AST part)`
    - Serialize instructions and get `C++ source code (parser part)` for ParserGen input
- **UnitTestParserGen**:
  - Unit test of **ParserGen**, input are all **UnitTestExecution** test cases rewritten in text format.
  - Assert on the ToString-ed AST. (shared)
  - Generate all parser in text format to C++ code
- **UnitTest**:
  - Link all cpp files in all other unit test projects so that all test cases can be run in one F5.
  - Test all generated parsers in **UnitTestParserGen**.
  - Assert on the ToString-ed AST. (shared)
- Since parser are written in different ways for different unit test projects, they are stored separately from unit test projects to share necessary files.
- Do not really write a file if the generated content doesn't change.
