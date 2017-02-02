# TODO

## Working On
* GacUI Resource
    * Don't need to specify item type when assigning to array properties (e.g. Table.(Rows|Columns))
* GacUI
    * Report errors with XML row/column number, instead of having Workflow_ValidateStatement
    * Strong-typed template checking (in XML, instead of delaying until compiling generated workflow script)

## Wait For A Few Releases
* Workflow
    * Auto property
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
* GacStudio.exe

## Proposal (Workflow State Machine)

### Goal
To implement
* Async operations
* Delayed operations
* State machine (visual state, animation)

### State Machine Interface
```
namespace system
{
    interface IStateMachine
    {
        func Start() : void;            /* Call to restart, will raise exception during execution */
        func Stop(ex : string) : void;  /* Call to stop, will raise exception if not started. */
        
        func GetIsExecuting() : bool;   
        event IsExecutingChanged();
        prop IsExecuting : bool {GetIsExecuting : IsExecutingChanged}
        
        event OnError(Exception^);      /* The current step goes wrong and continue to wait for more inputs */
        event OnFatal(Exception^);      /* The whole state machine goes wrong and has to stop */
        event OnStart();
        event OnExit();
    }
}
```

### Keywords
* `stateinput`
* `statefatal`
* `stateerror`

### Syntax
```
stateinput <Name>(<Argument>, ...);
statefatal "exception";     /* stop the state machine with a fatal error */
stateerror "exception";     /* redo the current stateinput statement with an error, only available in stateinput statement */
return;                     /* stop the state machine normally */

/* wait until received expected input */
switch(stateinput <IStateMachine^ expression, optional, will loop until it done, or fatal if there is a statefatal>)
{
    case <Name>(<Argument-Name>, ...):
    {
        ...
    }
    case <Event>(<Argument-Name>, ...):
    {
        ...
    }
    default:
    {
        ...
    }
}

/* join another stat machine */
var result : object = null;
switch(stateinput IStateMachine::Any({m1 m2 m3}))
{
    case m1.Result(r):{ result = r; }
    case m2.Result(r):{ result = r; }
    case m3.Result(r):{ result = r; }
}
```

### Sample (Workflow Script)
```
module test;
using system::*;
using presentation::controls::Gui*;

interface ICountDown : IStateMachine
{
    stateinput BeginCountDown();
    /* Equivalent to */
    func BeginCountDown() : void;
    func GetBeginCountDownEnabled() : bool;
    event BeginCountDownEnabledChanged() : bool;
    prop BeginCountDownEnabled : bool {GetBeginCountDownEnabled : BeginCountDownEnabledChanged}

    stateinput CountDown();
    stateinput DoNotCall();
    
    /* auto declare getter, setter and event */
    /* implementations are not generated in interface, but this one is implemented in state machine */
    prop Remains : int;
}
```

### Sample (Xml)
```xml
<Instance ref.CodeBehind="false" ref.Class="demo::MainWindow">
  <ref.Component Name="CountDown" Type="ICountDown^" Value="new CountDown^()"/>
  <Window ref.Name="self" Text="State Machine" ClientSize="x:480 y:320">
    <att.BoundsComposition-set PreferredMinSize="x:480 y:320"/>
    <!-- ignore layout settings -->
    <Button Enabled-bind="self.CountDown.BeginCountDownEnabled">
      <ev.Clicked-eval>{self.CountDown.Start(); self.CountDown.BeginCountDown();}</ev.Clicked-eval>
    </Button>
    <Button Enabled-bind="self.CountDown.CountDownEnabled">
      <ev.Clicked-eval>self.CountDown.CountDown();</ev.Clicked-eval>
    </Button>
    <Button Enabled-bind="self.CountDown.IsExecuting">
      <ev.Clicked-eval>self.CountDown.Stop();</ev.Clicked-eval>
    </Button>
    <Label Text-format="Remains: $(self.CountDown.Remains)"/>
  </Window>
  <ref.Members>
    <![CDATA[
        class CountDown : ICountDown
        {
	        statemachine
            {
                stateinput
                {
                    case BeginCountDown():{} /* If there are arguments, specify names only */
                    /*
                    Automatically updated before waiting:
                    BeginCountDownEnabled = true;
                    CountDownEnabled = false;
                    DoNotCallEnabled = false;
                    */
                }

                Remains = 10;
                while (true)
                {
                    if (Remains > 0)
                    {
                        stateinput
                        {
                            case CountDown():
                            {
                                Remains = Remains - 1;
                            }
                            /*
                            Automatically updated before waiting:
                            BeginCountDownEnabled = false;
                            CountDownEnabled = true;
                            DoNotCallEnabled = false;
                            */
                        }
                    }
                }
            }
        }
    ]]>
  </ref.Members>
</Instance>
```
