# TODO

## Working On
* Workflow
    * State Machine
        * WfCoroutineStatement: Base class of all coroutine statements, which will be totally removed after the ValidateSemantic pass
* GacUI Resource
    * Don't need to specify item type when assigning to array properties (e.g. Table.(Rows|Columns))
    * Handle resource file encoding if there is no BOM
        * Windows: Test UTF-8 correctness and local encoding correctness, may need to modify `vl::filesystem::File`
        * Others: Use local encoding (usually UTF-8)
* GacUI
    * Report errors with XML row/column number, instead of having Workflow_ValidateStatement
        * in `<Workflow>`
            * Create a full map from AST to position. The coordinate in the position will be used when an AST contains no codeRange.
    * Strong-typed template checking (in XML, instead of delaying until compiling generated workflow script)
    * Icon

## Wait For A Few Releases
* Workflow
    * async, delay, yield (provider written in C++).
    * **Workflow to C++ code generation with hint**.
        * Don't create IValueList if apply `{1 2 3}` on `List<int>` argument.
        * Use ::vl::vint for int in both 32 and 64 configurations.
* GacUI Resource
    * Add `<ref.Ctor>`, `<ref.Dtor>`
    * InheritableCustomWindow
    * InheritableCustomControl
    * GuiCustomControl::SetContainerComposition // using a special syntax
    * Make ItemSource from constructor argument to property
    * Localizable text template resource, adding str://
* GacGen.exe
    * Enable linking to external symbols
* DocTools
    * Support `decltype(auto)` type

## Low Property
* Vlpp
    * Regex supports UTF-16 (instead of UCS-2) on MSVC
        * Always convert to UTF-32 internally (**`vl::regex::Utf32Reader`**)
    * Redesign vl::parsing
        * No need to specify allow ambiguity or not
        * Escaping and Unescaping pairs (instead of only unescaping)
        * Calculate ambiguous **Parse** cases, pointing out which AST need to support ambiguity
        * Calculate ambiguous **ToString** cases
        * Generate **ToString** algorithm
        * Low overhead AST with reflection
        * Error message generation
        * Error recovering
        * Full CFG power, no limitation
        * Be able to assign to any properties (not just enum) in with statement
* Workflow
    * Macro
    * Context-Grammar Sensitive Macro
    * Virtual function
    * Class implements interface
* GacUI Resource
    * InstanceStyle:Replace
    * Visual State, State Machine, Animation
    * ev.Event-(eval|async|delayed)
* GacUI
    * Embedded Languages: Colorizer, AutoComplete
    * Abstract Graphics API
    * Chart, Ribbon, Dock Container
    * **(after animation is done)**
        * New predefined control templates, written in XML generated C++ code.
        * Retire Win7/Win8 control templates, rewrite them in tutorials.
        * Remove control style interfaces, controls talk to templates directly
    * Don't force re-rendering at every frame.
        * GuiGraphicsComposition::Render will detect bounds change
        * IGuiElement will detect property change
* GacStudio.exe

## Proposal (Workflow State Machine)

### Goal
To implement
* Async operations
* Delayed operations
* State machine (visual state, animation)

### Agenda
* State Machine Interface
* Core Syntax
* Extension (State Machine)
* Extension (Enumerable, $yield, $yieldBreak)
* Extension (Task)
* Sample

### State Machine Interface
```
namespace system
{
    enum StateMachineStatus
    {
        Waiting = 0,
        Executing = 1,
        Stopped = 2,
    }

    interface StateMachine
    {
        /* Call (Waiting -> Executing | Stopped), raise exception if (Executing | Stopped) */
        /* If raiseException == true, the function will raise the exception after storing to the Failure property */
        func Resume(raiseException : bool) : void;

        /* Stored the $raise/$retry result */
        prop Failure : Exception^ {const}
        prop Status : StateMachineStatus {const}
        event OnStatusChanged();
    }
}
```

### Core Syntax

* `$state_machine {...}` **expression**
    * Building a StateMachine^
* `$pause {}` **statement**
    * `$pause`, `return`, `break`, `continue` are not allowed inside `$pause`
* `return` **statement**
    * No expression
    * Stop the state machine
* `raise <EXPRESSION>` **statement**
    * Stop the state machine with a failure

```
/* Status == Waiting */
$state_machine
{
    /* Resume(): Status == Executing */
    for (i in range [1, 10])
    {
        /* Status == Waiting */
        $pause
        {
            /* Execute some code after Status == Waiting and before yielding the state machine */
        }
        /* Resume(): Status == Executing */
    }
    /* Status == Stopped */
    return;
    /* Status == Stopped with exception */
    raise "Something is happened!";
}
```

### Extension (State Machine Interface)

* `$input Name(a:Ta, b:Tb);` **declaration**
    * `func Name(a:Ta, b:Tb) : bool`
        * Returns false if a failed input causes a retry
        * No overloading
    * `prop NameEnabled : bool {const}`
        * `var <prop>NameEnabled : bool = false;`
        * `func GetNameEnabled() : bool { ... }`
        * `func SetNameEnabled(<value> : bool) : void { ... }`
* `$retry [<EXPRESSION>]` **statement**
    * Pause a state machine with a failure
    * Can only appear inside `$input`
    * Cause the current input fail
* `[$watch { ... }] ($input | $input_optional) if <INPUT-DECL>(arguments...) { ... } else if ... else ...` **statement**
    * If there is `$watch`
        * Cannot be followed by $input_optional
        * Failed input will go through the following $input
    * If there is no `$watch`
        * Pause the state machine with no failure
    * If there is `$input_optional`
        * If an input doesn't match the list, it is not considered failed, the state machine continue to run, and the input will be consumed by the next `$input` statement
    * If there is `$input`
        * If an input doesn't match the list, it is considered failed.
    * Failed input will cause a retry
        * Inside the original input
            * `$input_optional` doesn't produce failed input, so it is not an original input
            * `$input` inside a `$watch` is not an original input
            * Original input is the last `$input` statement that receives the failed input
        * If a retry is not initiated by `$retry` with an expression, then a default exceptions string is used
* `$join <STATE>;` **statement**
    * Only accept states that are declared **before** $join
* `$state [<NAME> ( ... )] { ... }` **declaration**
    * If there is a name with parameters (optional), than it can be `$join`
    * If there is no name, than this is the state machine for implementating the current interface

```
interface ICalculator : StateMachine
{
    $input Digit(i : int);
    $input Dot();
    $input Add();
    $input Mul();
    $input Equal();
    $input Clear();
    
    prop Value : string {const}
}

var calculator = new ICalculator^
{
    var valueFirst : string = "";
    var op : string = "";
    override prop Value : string = "0";
    
    func Update(value : string) : void
    {
        SetValue(value);
        valueFirst = value;
    }
    
    func Calculate() : void
    {
        if (valueFirst == "")
        {
            valueFirst = value;
        }
        else if (op == "+")
        {
            Update((cast double valueFirst) + (cast double Value));
        }
        else if (op == "*")
        {
            Update((cast double valueFirst) * (cast double Value));
        }
        else
        {
            raise $"Unrecognized operator: $(op)";
        }
    }
    
    $state Digits()
    {
        while (true)
        {
            $input_optional if Digit(i)
            {
                Value = Value & i;
            }
            else
            {
                break;
            }
        }
    }
    
    $state Integer()
    {
        $input_optional if Digit(i)
        {
            Value = i;
            $join Digits();
        }
    }
    
    $state Number()
    {
        $join Integer();
        $input_optional if Dot()
        {
            Value = Value & ".";
            $input Digit(i)
            {
                Value = Value & i;
                $join Digits();
            }
        }
    }

    $state
    {
        while (true)
        {
            $monitor
            {
                $join Number();
                $input if   Add()   {Calculate(); op = "+";}
                else if     Mul()   {Calculate(); op = "-";}
                else if     Equal() {Calculate(); op = "=";}
            }
            $input if Clear()
            {
                valueFirst = "";
                op = "";
                Value = "0";
            }
        }
    }
};
```

### Extension (Enumerable, $Yield)

#### Syntax
* `$pause` cannot be used inside a coroutine with a provider
* `return` is always mapped to `ReturnAndExit`
    * If `return` has an expression, than `ReturnAndExit` should also have an expression
* An exit operator is called at the end of the coroutine, all parameters are filled with default values.
    * If there is no exit operator, ignore
    * If there are multiple exit operators, than call `ReturnAndExit`, error if not exists.
* Pause operators and Exit operators cannot overload.

#### Build a coroutine using a provider
```
/* Use [Enumerable]StateMachine, the ^ sign should match the return type of EnumerableStateMachine */
$new Enumerable^
{
    for (i in range [1, 10])
    {
        /* Use [Enumerable]StateMachine.[Yield]And(Pause|Exit) */
        $Yield(i);
    }
    /* Use [Enumerable]StateMachine.ReturnAndExit */
    return;
}
```

#### Generated code
```
EnumerableStateMachine.Create
(
    func (impl : EnumerableStateMachine.IImpl*) : StateMachine^
    {
        return $state_machine
        {
            for (i in range [1, 10])
            {
                $pause
                {
                    EnumerableStateMachine.YieldAndPause(impl, i);
                }
            }
            {
                EnumerableStateMachine.ReturnAndExit(impl);
                return;
            }
        };
    }
);
```

#### Building a provider
```
class EnumerableStateMachine
{
    interface IImpl : Enumerator^
    {
        func OnNext(value : object) : void;
    }
    
    /* The first argument should match the declaration of the Create function */
    static func YieldAndPause(impl : IImpl*, value : object) : void
    {
        impl.OnNext(value);
    }

    /* The first argument should match the declaration of the Create function */
    static func ReturnAndExit(impl : IImpl*) : void
    {
    }
    
    /* The argument of the Create function should be a function, which has one argument and returns a StateMachine^ */
    static func Create(creator : func (impl : IImpl*) : StateMachine^) : Enumerable^
    {
        return new Enumerable^
        {
            override func CreateEnumerator() : Enumerator^
            {
                return new IImpl^
                {
                    var current = null;
                    var index = -1;
                    var stateMachine : StateMachine^ = null;
                    
                    override func OnNext(value : object) : void
                    {
                        index = index + 1;
                        current = value;
                    }

                    override func GetCurrent() : object
                    {
                        return current;
                    }

                    override func GetIndex() : int
                    {
                        return index;
                    }

                    override func Next() : bool
                    {
                        if (stateMachine is null)
                        {
                            stateMachine = creator(this);
                        }
                        
                        if (stateMachine.Status != Stopped)
                        {
                            stateMachine.Resume(true);
                        }
                        return stateMachine.Status != Stopped;
                    }
                }
            }
        }
    }
}
```

### Extension (Task)

```
```
