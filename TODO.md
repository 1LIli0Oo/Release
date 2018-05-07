# TODO

https://zhuanlan.zhihu.com/p/33778843

## Vlpp

* Regex supports UTF-16 (instead of UCS-2) on MSVC.
  * Always convert to UTF-32 internally (**`vl::regex::Utf32Reader`**).
* Redesign vl::parsing.
  * No need to specify ambiguity
  * Will print all ambiguous cases and marked AST node
  * ToString with hints and custom options
  * Print diff when updating AST (for IDE)
  * All existing features and backward compatible interface design

### (optional)

* Binary ITypeDescriptor provider format.
* API to import and export fake types (ITypeDescriptor that cannot be executed)

## Workflow

* **Workflow to C++ code generation with hint**.
  * Don't create IValueList if apply `{1 2 3}` on `List<int>` argument.
  * Leave spaces for user defined `#include`s or `using namespace`s.

### (optional)

* Support `<category>name` identifier, make generated code re-parsable.
* Separate assembly binary to types, instructions and debug informations.
* WorkflowCompiler.exe (x32/x64)
  * Enable external symbols
  * Compile
  * Binary Output (full assembly or types only)
  * C++ Codegen (x32/x64)

### (probably not do)

* Macro
* Context-Grammar Sensitive Macro
* Virtual function
* Class implements interface

## GacUI

#### Before 1.0
- [x] $ReturnAndExit for GuiAnimationCoroutine
- [x] Demo: DocumentEditor
- [x] Inheritable custom window / control
- [x] Ribbon
   - [x] RibbonTab (before/after header area)
   - [x] RibbonTabPage (highlighted)
   - [x] RibbonGroup
   - [x] Ribbon buttons
     - [x] `BigImage` property for `ToolstripCommand`
     - [x] `ToolstripButton' with text
     - [x] `ToolstripDropdownButton' with text
     - [x] `ToolstripSplitButton' with text
     - [x] Big `ToolstripButton' with text
     - [x] Big `ToolstripDropdownButton' with text (group text with dropdown triangle)
     - [x] Big `ToolstripSplitButton' with text
   - [x] Ribbon buttons transformation pattern controls (e.g. 3 big -> 3 small ->3small no text)
   - [x] `RibbonToolbars` with `<ToolstripGroup>`s
- [x] **Update Release**
- [ ] Ribbon
   - [x] RibbonGroup
     - [ ] Level down to dropdown button
     - [ ] Detail button
   - [ ]  `GuiRibbonGallery`
     - [ ] Level down to dropdown button
     - Provide ScrollUp / ScrollDown / Dropdown button
   - [ ] `GuiRibbonToolstripMenu` (`ContentComposition` property)
   - [ ]  `GuiBindableRibbonGalleryList`
     - Popup covered the whole button (gallery) or popup just below the button (dropdown)
     - When group is enabled, all group children are joined in sequence and display in the gallery control
     - In toolstrip menu, display group headers if there are groups
     - [ ] `GuiBindableRibbonGalleryBase`, which is the base class of gallery and gallery menu, but it is not a control
       - `GroupTitle` property
       - `GroupChildren` property, empty means there is no group
       - `ItemSource` property
         - When group is disabled, ItemSource is a collection of items.
         - When group is enabled, ItemSource is a collection of groups, and its title and children are defined by two properties above.
   - [ ] Ribbon toolstrip header (highlighted non-interactive menu item)
   - [ ] IconLabel (e.g. Word -> References -> Citations & Biblography -> Styles)
- [ ] CppMerge.exe reports error instead of crashes
- [ ] **Update Release**
- [ ] Add and query services from controls
- [ ] Normal text box supports surrogate pairs like document viewer
- [ ] RTF / HTML clipboard format for document viewer
- [ ] Demo: DocumentEditor
  - [ ] Load / Save
- [ ] Demo: TriplePhaseImageButton using `Context` property
- [ ] Demo: `<SharedSize>` and `<SharedSizeRoot>`, sync all buttons in item templates in a list control
- [ ] **Update Release**
- [ ] New default control templates with animation, written in XML generated C++ code.
- [ ] A window can be called to update all its controls' and components' template
- [ ] Tutorials use the new default control templates
- [ ] **Update Release**
- [ ] Enable Workflow script template for IGuiInstanceLoader written in text
- [ ] **Update Release**
- [ ] Inheritable custom window / control with `<ref.Parameter>`
- [ ] Resource should have name and version
- [ ] Depend on another resource, to decide loading order
- [ ] Demo: DocumentEditor: Split 1 Resource.xml to 3.
- [ ] **Update Release**
- [ ] (optional) `<eval Ref="Name"/>` and `<eval Eval="expression"/>` tags
- [ ] (optional) Update all control template properties to have `in` or `out` prefix
  - `in`: Template implementation should read
  - `out`: Template implementation should write
- [ ] Render focus
- [ ] BlackSkin window template handle window properties (border, buttons, ...)
- [ ] SM_CXPADDEDBORDER + SM_CXFRAME == 8, don't hardcode this in DarkSkin.xml. This is for the necessary border when the window is maximized.
- [ ] High DPI for Direct2D (GDI will blur)
- [ ] **Update Release**

#### Graphics
- [ ] MetaImageElement and MetaImage data structure
- [ ] Remove PolygonElement
- [ ] Default non-text element renderer using MetaImageElement
- [ ] Replacing GDI and D2D non-text element renderers
- [ ] Meta3DElement and Meta3D data structure
- [ ] Default Meta3DElement renderer using MetaImageElement with a surface sorting based algorithm

#### Controls
- [ ] Chart
- [ ] Ribbon
- [ ] Dock Container
- [ ] Icon

### (probably not do)

* GuiCustomControl::SetContainerComposition // using a special syntax
* InstanceStyle:Replace

## GacGen.exe

* Enable linking to external symbols

### (optional)

* In the final pass, only workflow scripts are printed
  * Use WorkflowCompiler.exe to do codegen externally

## GacStudio.exe

## DocTools

* Rewrite in C++
