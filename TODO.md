# TODO

## Working On
* GacUI Resource
    * Don't need to specify item type when assigning to array properties (e.g. Table.(Rows|Columns))
    * Correctly handle spaces when saving `<Doc/>`
* GacUI
    * Report errors with XML row/column number, instead of having Workflow_ValidateStatement
        * in XML
        * in `<InstanceStyle>`
        * in `<Workflow>`
    * Strong-typed template checking (in XML, instead of delaying until compiling generated workflow script)
    * Icon

## Wait For A Few Releases
* Workflow
    * Auto property
        * Put `WfClassMember` inside `WfDeclaration`
        * Add `WfVirtual(Expression|Statement|Declaration)`, to represent an "expandable" AST unit (e.g. bind)
            * `WfExpression`
            * `List<WfStatement>`
            * `List<WfDeclaration>`
        * CONFIG:
            * {}
            * {const}
            * {not observe}
            * {const, not observe}
        * For interface: `prop NAME : TYPE CONFIG;`
            * Expand to Getter / Setter / Event / Property
        * For class: `prop NAME : TYPE = EXPRESSION CONFIG;`
            * Expand to [@cpp:Private]Variable / Getter / Setter / Event / Property
        * For class (override): `override prop NAME : TYPE = EXPRESSION CONFIG;`
            * Expand to [@cpp:Private]Variable / Getter / Setter
    * Macro
    * State Machine
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
    * Localizable text template resource
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

* `$pause {}`
* `$return;`
* `$raise <EXCEPTION>;`
* `$input Name(a:Ta, b:Tb);`
    * `func Name(a:Ta, b:Tb) : void`
    * `prop NameEnabled : bool {const}`

```
/* Status == Waiting */
new StateMachine^
{
    <OTHER-DECLARATIONS>

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
        $return;
        /* Status == Stopped with exception */
        $raise "Something is happened!";
    }
}
```

### Extension (State Machine Interface)

* `$switch { $pause{} case ... }`

```
$switch
{
    $pause
    {
        /* Executing some code ... */
        /* Set all <Method>Enabled properties, raise all <Method>EnabledChanged events */
    }
    case Method(arg1 [: type] , ...):
    {
        /* This method is declared in the returning interface type */
    }
    case value.Event(arg1 [: type], ...):
    {
        /* Some event */
    }
    /* Unimplemented methods raise exceptions */
}
```

### Extension (Enumerable, $yield, $yieldBreak)

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
```
/* Use [Enumerable]StateMachine, the ^ sign should match the return type of EnumerableStateMachine */
$new Enumerable^
{
    for (i in range [1, 10])
    {
        /* Use [Enumerable]StateMachine.[yield](Pause|Return) */
        $yield(i);
    }
    /* Use [Enumerable]StateMachine.[yieldBreak](Pause|Return) */
    $yieldBreak();
}
```

* Is translated to
```
EnumerableStateMachine.Create
(
    func (impl : EnumerableStateMachine.IImpl*) : StateMachine^
    {
        return new StateMachine^
        {
            {
                for (i in range [1, 10])
                {
                    $pause
                    {
                        EnumerableStateMachine.yield(impl, i);
                    }
                }
                {
                    EnumerableStateMachine.yieldBreak(impl);
                    $return;
                }
            }
        }
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
    static func yieldPause(impl : IImpl*, value : object) : void
    {
        impl.OnNext(value);
    }

    /* The first argument should match the declaration of the Create function */
    static func yieldBreakReturn(impl : IImpl*) : void
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

### Sample

* Workflow Script
```
module test;
using system::*;
using presentation::controls::Gui*;

interface ICountDown : StateMachine
{
    $input BeginCountDown();
    $input CountDown();
    $input DoNotCall();
    prop Remains : int {const}
}
```

* XML
```xml
<Instance ref.CodeBehind="false" ref.Class="demo::MainWindow">
  <ref.Members>
    var CountDown : ICountDown^ = null;
  </ref.Members>
  <Window ref.Name="self" Text="State Machine" ClientSize="x:480 y:320">
    <att.BoundsComposition-set PreferredMinSize="x:480 y:320"/>
    <!-- ignore layout settings -->
    <Button Enabled-bind="self.CountDown is null">
      <ev.Clicked-eval>{self.CountDown = self.CreateCountDown(); self.CountDown.BeginCountDown();}</ev.Clicked-eval>
    </Button>
    <Button Enabled-bind="self.CountDown.CountDownEnabled ?? false">
      <ev.Clicked-eval>self.CountDown.CountDown();</ev.Clicked-eval>
    </Button>
    <Button Enabled-bind="self.CountDown is not null">
      <ev.Clicked-eval>self.CountDown = self.CreateCountDown();</ev.Clicked-eval>
    </Button>
    <Label Text-format="Remains: $(self.CountDown.Remains)"/>
  </Window>
  <ref.Members>
    <![CDATA[
        func CreateCountDown() : ICountDown^
        {
            return new ICountDown^
            {
                override prop Remains : int = 10 {const}

                {
                    $switch
                    {
                        case BeginCountDown():{}
                    }

                    while (Remains > 0)
                    {
                        $switch
                        {
                            case CountDown():
                            {
                                Remains = Remains - 1;
                            }
                        }
                    }
                }
            }
        }
    ]]>
  </ref.Members>
</Instance>
```
