use zed_extension_api as zed;

struct ErrorLensExtension;

impl zed::Extension for ErrorLensExtension {
    fn new() -> Self {
        Self
    }
}

zed::register_extension!(ErrorLensExtension);
