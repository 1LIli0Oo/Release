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
- [ ] Depend on another resource, to decide loading order
  - [ ] Resource should have name and version, resource needs to specify names of all depended resources, versions should be all identical.
  - [ ] `GacDep.ps1` searches for all `Resource.xml` (maybe different name), and generate lists files of input files and output binary files, dependencies, binary files out dated or not, log folders, and build order, assuming `GacGen.ps1`.
  - [ ] `GacBuild.ps1` reads the output of `GacDep.ps1` and do incremental builds.
  - [ ] `GacClear.ps1` deletes all log folders of resources, using the output of `GacDep.ps1`, which causes `GacBuild.ps1` to do full build after that.
  - [ ] `GacGen.exe` supports all operations above.
  - [ ] Add a metadata xml in front of binary resource data, so that GacUI knows how to load them in order.
- [x] Inheritable custom window / control with `<ref.Parameter>`
- [x] Change `GacConfig\Res` to `ResX86` and `ResX64`, with an additional `Assembly` option, to produce platform-dependended
  - Scripted resource binary
  - Scripted compressed resource binary
  - Assembly
- [x] GacGen will always output all `Res*` supported binaries to `*.xml.log` folder
- [ ] Resource import item/folder from depended resources
- [ ] Demo: DocumentEditor: Split 1 Resource.xml to 3.
- [ ] **Update Release**
- [ ] Known issue
  - [ ] Word doesn't recognize embedded GIF represented by data URL in HTML clipboard format.
  - [ ] AddressBook demo's new contact window default height too large.
  - Find someday to fix it
- [ ] **Update Release**
- [ ] Normal text box supports surrogate pairs like document viewer
- [ ] Demo: TriplePhaseImageButton using `Context` property
- [ ] Demo: `<SharedSize>` and `<SharedSizeRoot>`
  - [ ] sync all buttons in item templates in a list control
  - [ ] Two columns in repeat flow
- [ ] **Update Release**
- [ ] Workflow Codegen
  - [ ] When some `ref.CodeBehind="false"` classes inherit from a `ref.CodeBehind="true"` one, group them in a different pair of files.
  - [ ] `USERIMPL_BEGIN` and `USERIMPL_END` for header includes, cpp includes and class members.
  - [ ] Put `USERIMPL` series macros in `VlppWorkflowLibrary.h`
- [ ] Document clipboard data should have version
- [ ] **Update Release**
- [ ] CppMerge.exe reports error instead of crashes
- [ ] Add and query services from controls
- [ ] **Update Release**
- [ ] New default control templates with animation, written in XML generated C++ code.
- [ ] A window can be called to update all its controls' and components' template
- [ ] Tutorials use the new default control templates
- [ ] **Update Release**
- [ ] Render focus
- [ ] BlackSkin window template handle window properties (border, buttons, ...)
- [ ] SM_CXPADDEDBORDER + SM_CXFRAME == 8, don't hardcode this in DarkSkin.xml. This is for the necessary border when the window is maximized.
- [ ] High DPI for Direct2D (GDI will blur)
- [ ] Window Icon
- [ ] **Update Release**

#### Before 1.0 (Optional)
- [ ] `<eval Ref="Name"/>` and `<eval Eval="expression"/>` tags
- [ ] Enable Workflow script template for IGuiInstanceLoader written in text

#### Graphics
- [ ] MetaImageElement and MetaImage data structure
- [ ] Remove PolygonElement
- [ ] Default non-text element renderer using MetaImageElement
- [ ] Replacing GDI and D2D non-text element renderers
- [ ] Meta3DElement and Meta3D data structure
- [ ] Default Meta3DElement renderer using MetaImageElement with a surface sorting based algorithm

#### Controls
- [ ] Chart
- [ ] Dock Container

#### Binders
- [ ] Web assembly
- [ ] XML Metadata output for codegen written by users

## GacGen.exe

* Enable linking to external symbols

### (optional)

* In the final pass, only workflow scripts are printed
  * Use WorkflowCompiler.exe to do codegen externally

## GacStudio.exe

## DocTools

* Rewrite in C++
