# TODO

## Working On
* Workflow
    * Auto property
        * Add `WfVirtual(Statement|Declaration)`, to represent an "expandable" AST unit (e.g. bind)
            * `WfStatement`
            * `List<WfDeclaration>`
        * CONFIG:
            * {}
            * {const}
            * {not observe}
            * {const, not observe}
        * For interface: `prop NAME : TYPE CONFIG`
            * Expand to Getter / Setter / Event / Property
        * For new interface (override): `override prop NAME : TYPE = EXPRESSION CONFIG`
            * Expand to [@cpp:Private]Variable / Getter / Setter
            * Check CONFIG
        * For class: `prop NAME : TYPE = EXPRESSION CONFIG`
            * Expand to [@cpp:Private]Variable / Getter / Setter / Event / Property
        * When implementing a property, the setter function is always generated
            * If there is `const`, the setter will not be registered into the property
    * State Machine
* GacUI Resource
    * Don't need to specify item type when assigning to array properties (e.g. Table.(Rows|Columns))
    * Handle resource file encoding if there is no BOM
        * Windows: Test UTF-8 correctness and local encoding correctness, may need to modify `vl::filesystem::File`
        * Others: Use local encoding (usually UTF-8)
    * Output file using local encoding
* GacUI
    * Report errors with XML row/column number, instead of having Workflow_ValidateStatement
        * in `<Workflow>`
            * Create a full map from AST to position. The coordinate in the position will be used when an AST contains no codeRange.
    * Strong-typed template checking (in XML, instead of delaying until compiling generated workflow script)
    * Icon

## Wait For A Few Releases
* Workflow
    * Macro
    * Context-Grammar Sensitive Macro
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
    * async, delay, yield (provider written in C++).
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

        /* Stored the $raise result */
        prop Failure : Exception^ {const}
        prop Status : StateMachineStatus {const}
        event OnStatusChanged();
    }
}
```

### Core Syntax

* `$coroutine {...}` **expression**
    * Building a StateMachine^
* `$pause {}` **statement**
* `return` **statement**
    * No expression

```
/* Status == Waiting */
$coroutine
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
    * `prop NameEnabled : bool {const}`
        * `var <prop>NameEnabled : bool = false;`
        * `func GetNameEnabled() : bool { ... }`
        * `func SetNameEnabled(<value> : bool) : void { ... }`
* `$switch { $case <$INPUT-DECL>: { ... } ... [$default [ = continue]: { ... }] }` **statement**
    * If there is `$default = continue`
        * Failed input will not cause a retry
        * Continue to execute until the next `$switch`, and use the current input as the input
        * In this case we don't call it **failed input**, until the next `$switch` failed
* `$watch { ... } $switch { ... }` **statement**
    * Failed input will fall into `$switch` directly
    * If there is no **appropriate** `$watch` to catch failed input, the failed input cause a retry immediately
* `$join <STATE>;` **statement**
    * Cannot be directly or indirectly recursive
    * Which means `$join` and `$state` should not exceed type 3 grammar
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
            Update(value);
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
            throw $"Unrecognized operator: $(op)";
        }
    }
    
    $state Integer()
    {
        $switch
        {
            $case Digit(i : int): { Value = i; }
            $default = continue: {}
        }
        while (true)
        {
            $switch
            {
                $case Digit(i : int): { Value = Value & i; }
                $default = continue: {}
            }
        }
    }
    
    $state Number()
    {
        $join Integer();
        $switch
        {
            $case Dot() { Value = Value & "."; }
        }
        $join Integer();
    }

    $state
    {
        while (true)
        {
            $watch
            {
                $join Number();
                $switch
                {
                    $case Add(): { Calculate(); op = "+"; }
                    $case Mul(): { Calculate(); op = "-"; }
                    $case Equal(): { Calculate(); op = "="; }
                }
            }
            $switch
            {
                $case Clear():
                {
                    valueFirst = "";
                    op = "";
                    Value = "0";
                }
            }
        }
    }
};
```

### Extension (Enumerable, $Yield)

#### Step 1 (Using core syntax)

```
new Enumerable^
{
    override func CreateEnumerator() : Enumerator^
    {
        return new Enumerator^
        {
            var current = null;
            var index = -1;
            var notStopped = true;
        
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
                if (notStopped)
                {
                    Resume(true);
                    if (notStopped = Status != Stopped)
                    {
                        index = index + 1;
                    }
                }
                return notStopped;
            }
            
            {
                for (i in range [1, 10])
                {
                    current = i;
                    $pause {}
                }
            }
        }
    }
}
```

#### Step 2 (Using extension)

* This coroutine
    * `$pause` cannot be used inside a coroutine with a provider
    * `return` is always mapped to `ReturnAndExit`
        * If `return` has an expression, than `ReturnAndExit` should also have an expression
    * An exit operator is called at the end of the coroutine, all parameters are filled with default values.
        * If there is no exit operator, ignore
        * If there are multiple exit operators, than call `ReturnAndExit`, error if not exists.
    * Pause operators and Exit operators cannot overload.
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

* Is translated to
```
EnumerableStateMachine.Create
(
    func (impl : EnumerableStateMachine.IImpl*) : StateMachine^
    {
        return $coroutine
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

* Using a user-defined provider
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
