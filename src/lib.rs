use std::os::raw::{c_char};
use std::ffi::{CString, CStr};

#[no_mangle]
pub fn say_hello(name: *const c_char) -> *mut c_char {
    let name_cstr = unsafe { CStr::from_ptr(name) };

    let name_str = match name_cstr.to_str() {
        Err(_) => "ERROR",
        Ok(string) => string,
    };

    let greeting = format!("Hello {}", name_str);
    
    CString::new(greeting).unwrap().into_raw()
}
