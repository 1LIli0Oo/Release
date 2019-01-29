# TODO

https://zhuanlan.zhihu.com/p/39369370

# GacUI 1.0

- [x] Fix `<childControl Font-bind="parentControl.Font"/>` script crash.
- [x] High DPI for Direct2D (GDI will blur)
- [ ] Cannot change column size during datagrid's bounds changing, which is by designed and this could be solved by calling InvokeInMainThread. But new feature for solving this is under considering
  - [ ] Considering GuiBindableDataGrid updating columns' sizes according to configuration automatically, and call `GuiControl::InvokeOrDelayIfRendering` (indirectly) inside `DataColumn::NotifyAllColumnsUpdate` when necessary.
  - [ ] Like a table, a column can use `Absolute`, `Draggable` and `Percentage` to specify a column size. Only when a column is draggable, users can use their mouse to change the size of a column, and then trigger `IColumnItemView::SetColumnSize`
- [ ] **Update Release**
- [ ] Consider drag and drop support, with column drag and drop
- [ ] New item arranger that can accept a `GuiRepeatCompositionBase`
- [ ] **Update Release**
- [ ] New default control templates with animation, written in XML generated C++ code.
- [ ] A window can be called to update all its controls' and components' template
- [ ] Tutorials use the new default control templates
- [ ] **Update Release**
- [ ] Fix GacGen reports only "error dumping resource file" while the resource file contains some syntax errors preventing GacGen from reading it
  - Unable to repro

**ON GOING**: Document repo

# GacUI 2.0

## Vlpp

* Regex supports UTF-16 (instead of UCS-2) on MSVC.
  * Always convert to UTF-32 internally (**`vl::regex::Utf32Reader`**).
* Redesign vl::parsing.
  * No need to specify ambiguity
  * Will print all ambiguous cases and marked AST node
  * ToString with hints and custom options
  * Print diff when updating AST (for IDE)
  * All existing features and backward compatible interface design
* Binary ITypeDescriptor provider format.
* API to import and export fake types (ITypeDescriptor that cannot be executed)

## Workflow

* Don't create IValueList if apply `{1 2 3}` on `List<int>` argument.
* Support `<category>name` identifier, make generated code re-parsable.
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

#### Before 1.0 (Optional)
- [ ] `<eval Ref="Name"/>` and `<eval Eval="expression"/>` tags
- [ ] Enable Workflow script template for IGuiInstanceLoader written in text
- [ ] INativeImage::SaveToStream handle correctly for git format. It is possible that LoadFromStream need to process diff between git raw frames.

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
- [ ] Touch support

#### Binders
- [ ] Web assembly
- [ ] XML Metadata output for codegen written by users

## GacGen.exe

* Enable linking to external symbols
* In the final pass, only workflow scripts are printed
  * Use WorkflowCompiler.exe to do codegen externally

## GacStudio.exe

## DocTools

* Rewrite in C++
