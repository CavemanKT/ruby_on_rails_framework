// Start Exercise controller to ensure form submission works correctly
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "button"];

  connect() {
    console.log("Start Exercise controller connected");
  }

  submit(event) {
    console.log("Start Exercise button clicked");
    
    // 防止重复提交
    if (this.buttonTarget.disabled) {
      event.preventDefault();
      return;
    }
    
    // 禁用按钮防止重复点击
    this.buttonTarget.disabled = true;
    this.buttonTarget.textContent = "Starting...";
    
    // 确保表单提交
    console.log("Submitting form...");
    this.formTarget.submit();
  }
}
