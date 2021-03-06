---
title: Editor
page_title: Editor  | Telerik UI for ASP.NET Core Tag Helpers
description: "Learn the basics when working with the Editor tag helper for ASP.NET Core (MVC 6 or ASP.NET Core MVC)."
slug: taghelpers_editor_aspnetcore
---

# Editor Tag Helper Overview

The Editor tag helper helps you configure the Kendo UI Editor widget in ASP.NET Core applications.

## Basic Usage

The following example demonstrates how to define the Editor by using the Editor tag helper.

###### Example

		<kendo-editor name="editor">
		</kendo-editor>

## Configuration

The Editor tag helper tools collection is passed through the nest `<tools>` tag.

###### Example

```tab-tagHelper
		<kendo-editor name="editor">
			<tools>
        <tool name="bold" />
        <tool name="italic" />
				<tool name="underline" />
        <tool name="fontName" />
			</tools>
		</kendo-editor>
```
```tab-cshtml
		@(Html.Kendo().Editor()
				.Name("editor")
				.Tools(tools => tools
						.Clear()
						.Bold()
						.Italic()
						.Underline()
						.FontName()
				)
		)
```

The tools in the tools collection can be adjusted and set up via the `<tools>` tag and their items collection can be defined via the `<tool-items>` and `<tool-item>` tags.

###### Example

```tab-tagHelper
	<kendo-editor name="editor">
		<tools>
			<tool name="fontName">
				<tool-items>
					<tool-item text="Default site font" value="Arial,Verdana,sans-serif" />
					<tool-item text="Monospaced font" value="monospace" />
				</tool-items>
			</tool>
		</tools>
	</kendo-editor>
```
```tab-cshtml
	@(Html.Kendo().Editor()
			.Name("editor")
			.Tools(tools => {
					tools.Clear();
					tools.FontName(items => items
							.Add("Default site font", "Arial, Verdana, sans - serif")
							.Add("Monospaced", "monospace")
					);
			})
	)
```

You can specify content in the Editor tag helper by using the `<content>` tag or the `value` attribute.

###### Example

```tab-tagHelper
	<kendo-editor name="editor">
			<content>
					<p>Some content.</p>
			</content>
	</kendo-editor>
```
```tab-tagHelper
	<kendo-editor name="editor" value="<p>Some content</p>">
	</kendo-editor>
```
```tab-cshtml
	@(Html.Kendo().Editor()
			.Name("editor")
			.Value(@<text>
				<p>Some content.</p>
			</text>)
	)
```

###### Example

ImageBrowser and FileBrowser dialogs are configured through the `<image-browser>` and `<file-browser>` tags.

```tab-tagHelper
	<kendo-editor name="editor">
    <image-browser file-types="*.png,*.gif,*.jpg,*.jpeg">
        <transport upload-url="/ImageBrowser/Upload" image-url="/shared/UserFiles/Images/{0}">
            <create url="/ImageBrowser/Create"/>
            <read url="/ImageBrowser/Read" />
            <destroy url="/ImageBrowser/Destroy" />
        </transport>
    </image-browser>
    <file-browser>
        <transport upload-url="/FileBrowser/Upload" file-url="/shared/UserFiles/Images/{0}">
            <create url="/FileBrowser/Create" />
            <read url="/FileBrowser/Read" />
            <destroy url="/FileBrowser/Destroy" />
        </transport>
    </file-browser>
	</kendo-editor>
```
```tab-cshtml
	@(Html.Kendo().Editor()
		.Name("editor")
		.ImageBrowser(imageBrowser => imageBrowser
				.Image("~/shared/UserFiles/Images/{0}")
				.Read("Read", "ImageBrowser")
				.Create("Create", "ImageBrowser")
				.Destroy("Destroy", "ImageBrowser")
				.Upload("Upload", "ImageBrowser")
		)
		.FileBrowser(fileBrowser => fileBrowser
				.File("~/shared/UserFiles/Images/{0}")
				.Read("Read", "FileBrowser")
				.Create("Create", "FileBrowser")
				.Destroy("Destroy", "FileBrowser")
				.Upload("Upload", "FileBrowser")
		)
	)
```

Serialization, Deserialization and PasteCleanup settings are configured with the `<serialization>`, `<deserialization>`, `<paste-cleanup>` tags.

###### Example

```tab-tagHelper
	<kendo-editor name="editor">
    <deserialization custom="myDeserialization" />
    <serialization custom="mySerialization" entities="false" />
		<paste-cleanup custom="myPasteCleanup" keep-new-lines="true" />
	</kendo-editor>
```
```tab-cshtml
	@(Html.Kendo().Editor()
		.Name("editor")
    .Deserialization(deserialization => deserialization.Custom("myDeserialization"))
    .Serialization(serialization => serialization.Custom("mySerialization").Entities(false))
		.PasteCleanup(pasteCleanup => pasteCleanup.Custom("myPasteCleanup").KeepNewLines(true))
	)
```

Other Editor options you can configure through inner tags are PDF export (`<pdf>`), immutables (`<immutables>`), resizable (`<resizable>`) and messages (`<messages>`).

###### Example

```tab-tagHelper
	<kendo-editor name="editor">
    <immutables enabled="true" />
    <resizable toolbar="true" content="true" />
    <pdf paper-size="A4" />
    <messages bold="Strong" />
	</kendo-editor>
```
```tab-cshtml
	@(Html.Kendo().Editor()
		.Name("editor")
		.Immutables(true)
    .Resizable(resizable => resizable.Toolbar(true).Content(true))
    .Pdf(pdf => pdf.PaperSize("A4"))
    .Messages(messages => messages.Bold("Strong"))
	)
```

## See Also

* [Overview of Telerik UI for ASP.NET Core]({% slug overview_aspnetmvc6_aspnetmvc %})
* [Get Started with Telerik UI for ASP.NET Core in ASP.NET Core Projects]({% slug gettingstarted_aspnetmvc6_aspnetmvc %})
* [Get Started with Telerik UI for ASP.NET Core in ASP.NET Core Projects on Linux]({% slug gettingstartedlinux_aspnetmvc6_aspnetmvc %})
* [Known Issues with Telerik UI for ASP.NET Core]({% slug knownissues_aspnetmvc6_aspnetmvc %})
