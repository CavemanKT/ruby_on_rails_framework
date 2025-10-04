// Breathing exercise controller
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "circle",
    "phaseLabel",
    "countdown",
    "timer",
    "cycle",
    "playButton",
    "pauseButton",
    "stopButton",
    "completionMessage",
    "progress",
    "progressRing",
    "loadingOverlay",
  ];
  static values = { sessionId: String, phases: Object };

  connect() {
    this.isRunning = false;
    this.isPaused = false;
    this.currentTime = 0;
    this.interval = null;
    this.currentPhase = "inhale";
    this.phaseTime = 0;
    this.currentCycle = 1;
    this.totalCycles = 5;
    this.startedAt = new Date().toISOString();
    this.autoSaveInterval = null; // 添加自动保存间隔

    // 初始化动画
    this.updateDisplay();
    this.initializePhases();

    // 添加页面离开前的保存
    this.addBeforeUnloadListener();
  }

  // 添加页面离开监听器
  addBeforeUnloadListener() {
    window.addEventListener("beforeunload", () => {
      if (this.isRunning || this.currentTime > 0) {
        this.saveProgress();
      }
    });
  }

  initializePhases() {
    // 确保 phases 数据正确传递
    if (!this.phasesValue || Object.keys(this.phasesValue).length === 0) {
      this.phasesValue = {
        inhale: { duration: 4, label: "Breathe In", color: "blue" },
        hold: { duration: 4, label: "Hold", color: "green" },
        exhale: { duration: 6, label: "Breathe Out", color: "purple" },
      };
    }
  }

  disconnect() {
    this.stop();
  }

  toggle() {
    if (this.isRunning) {
      this.pause();
    } else {
      this.start();
    }
  }

  start() {
    this.isRunning = true;
    this.isPaused = false;
    this.playButtonTarget.textContent = "Pause";
    this.playButtonTarget.classList.add("hidden");
    this.pauseButtonTarget.classList.remove("hidden");

    this.interval = setInterval(() => {
      this.tick();
    }, 1000);

    // 添加自动保存（每30秒保存一次）
    this.autoSaveInterval = setInterval(() => {
      this.saveProgress();
    }, 30000);
  }

  pause() {
    this.isRunning = false;
    this.isPaused = true;
    this.playButtonTarget.textContent = "Resume";
    this.playButtonTarget.classList.remove("hidden");
    this.pauseButtonTarget.classList.add("hidden");

    clearInterval(this.interval);

    // 暂停时保存进度
    this.saveProgress();
  }

  async stop() {
    this.isRunning = false;
    this.isPaused = false;
    clearInterval(this.interval);
    clearInterval(this.autoSaveInterval);

    // 停止时保存进度并重定向到历史页面
    await this.saveProgressAndRedirect();

    // 重置到初始状态
    this.currentTime = 0;
    this.currentCycle = 1;
    this.currentPhase = "inhale";
    this.phaseTime = 0;

    this.updateDisplay();
    this.playButtonTarget.textContent = "Start Exercise";
    this.playButtonTarget.classList.remove("hidden");
    this.pauseButtonTarget.classList.add("hidden");
  }

  async saveProgress() {
    if (this.currentTime === 0) return; // 没有进度时不保存

    try {
      const progressData = {
        duration: this.currentTime,
        cycles_completed: this.currentCycle - 1,
        total_phases_completed: (this.currentCycle - 1) * 3,
        phases_breakdown: this.generatePhasesBreakdown(),
        started_at: this.startedAt,
        finished_at: new Date().toISOString(),
        is_progress_save: true, // 标记这是进度保存，不是完成
      };

      console.log("Saving progress:", progressData);

      const response = await fetch(
        `/breathing/${this.sessionIdValue}/finish`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
              .content,
          },
          body: JSON.stringify(progressData),
        }
      );

      if (response.ok) {
        console.log("Progress saved successfully");
      } else {
        console.error("Failed to save progress");
      }
    } catch (error) {
      console.error("Error saving progress:", error);
    }
  }

  async saveProgressAndRedirect() {
    if (this.currentTime === 0) {
      // 没有进度时直接重定向
      window.location.href = "/breathing/history";
      return;
    }

    try {
      const progressData = {
        duration: this.currentTime,
        cycles_completed: this.currentCycle - 1,
        total_phases_completed: (this.currentCycle - 1) * 3,
        phases_breakdown: this.generatePhasesBreakdown(),
        started_at: this.startedAt,
        finished_at: new Date().toISOString(),
        is_progress_save: true, // 标记这是进度保存，不是完成
      };

      console.log("Saving progress and redirecting:", progressData);

      const response = await fetch(
        `/breathing/${this.sessionIdValue}/finish`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
              .content,
          },
          body: JSON.stringify(progressData),
        }
      );

      if (response.ok) {
        console.log("Progress saved successfully, redirecting to history");
        // 保存成功后重定向到历史页面
        window.location.href = "/breathing/history";
      } else {
        console.error("Failed to save progress");
        // 即使保存失败也重定向到历史页面
        window.location.href = "/breathing/history";
      }
    } catch (error) {
      console.error("Error saving progress:", error);
      // 即使出错也重定向到历史页面
      window.location.href = "/breathing/history";
    }
  }

  // 修复 tick 方法
  tick() {
    this.currentTime++;
    this.phaseTime++;

    const phaseData = this.phasesValue[this.currentPhase];
    const phaseDuration = phaseData.duration;

    // 检查是否需要切换到下一个阶段
    if (this.phaseTime >= phaseDuration) {
      this.nextPhase();
    }

    this.updateDisplay();

    // 移除这里的完成检查，因为已经在 nextPhase 中处理
  }

  // 修复 nextPhase 方法
  nextPhase() {
    this.phaseTime = 0;

    // 切换到下一个阶段
    switch (this.currentPhase) {
      case "inhale":
        this.currentPhase = "hold";
        break;
      case "hold":
        this.currentPhase = "exhale";
        break;
      case "exhale":
        this.currentPhase = "inhale";
        this.currentCycle++;

        // 检查是否完成所有周期（修复：在周期增加后立即检查）
        if (this.currentCycle > this.totalCycles) {
          this.complete();
          return; // 重要：立即返回，不继续执行
        }
        break;
    }
  }

  updateDisplay() {
    // 更新阶段标签和倒计时
    const phaseData = this.phasesValue[this.currentPhase];
    const timeLeft = phaseData.duration - this.phaseTime;

    this.phaseLabelTarget.textContent = phaseData.label;
    this.countdownTarget.textContent = timeLeft;

    // 更新周期和总时间
    this.cycleTarget.textContent = this.currentCycle;
    this.timerTarget.textContent = this.formatTime(this.currentTime);

    // 更新动画圆圈
    this.updateCircleAnimation();

    // 更新进度环
    this.updateProgressRing();
  }

  updateCircleAnimation() {
    const phaseData = this.phasesValue[this.currentPhase];
    const progress = this.phaseTime / phaseData.duration;

    // 根据阶段改变圆圈大小和颜色
    let scale = 1;
    switch (this.currentPhase) {
      case "inhale":
        scale = 1 + progress * 0.5; // 吸气时放大
        this.circleTarget.style.borderColor = "rgba(59, 130, 246, 0.8)"; // blue
        break;
      case "hold":
        scale = 1.5; // 保持最大
        this.circleTarget.style.borderColor = "rgba(34, 197, 94, 0.8)"; // green
        break;
      case "exhale":
        scale = 1.5 - progress * 0.5; // 呼气时缩小
        this.circleTarget.style.borderColor = "rgba(147, 51, 234, 0.8)"; // purple
        break;
    }

    this.circleTarget.style.transform = `scale(${scale})`;
    this.circleTarget.style.transition = "transform 0.1s ease-in-out";
  }

  updateProgressRing() {
    const totalDuration = this.totalCycles * 14; // 5 cycles * (4+4+6) seconds
    const progress = Math.min(this.currentTime / totalDuration, 1);
    const circumference = 754; // 2 * PI * 120
    const offset = circumference - progress * circumference;

    this.progressTarget.style.strokeDashoffset = offset;
  }

  formatTime(seconds) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  }

  async complete() {
    this.stop();
    this.completionMessageTarget.classList.remove("hidden");

    // 只有完成5个周期才能获得积分
    if (this.currentCycle > this.totalCycles) {
      await this.finish();
    } else {
      // 即使没有完成5个周期，也要保存进度并重定向到历史页面
      await this.saveProgressAndRedirect();
    }
  }

  async finish() {
    this.showLoading();

    // 准备详细数据
    const exerciseData = {
      duration: this.currentTime,
      cycles_completed: this.currentCycle - 1,
      total_phases_completed: (this.currentCycle - 1) * 3,
      phases_breakdown: this.generatePhasesBreakdown(),
      started_at: this.startedAt,
      finished_at: new Date().toISOString(),
      is_completion: true, // 标记这是完成保存
    };

    console.log("Sending exercise data:", exerciseData);

    try {
      const response = await fetch(
        `/breathing/${this.sessionIdValue}/finish`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
              .content,
          },
          body: JSON.stringify(exerciseData),
        }
      );

      if (response.ok) {
        const data = await response.json();
        console.log("Exercise completed successfully:", data);
        this.showPointsEarned(data.calm_points);
        setTimeout(() => {
          window.location.href = "/breathing/history";
        }, 2000);
      } else {
        const errorData = await response.json();
        console.error("Server error:", errorData);
        throw new Error(`Server error: ${response.status}`);
      }
    } catch (error) {
      console.error("Error finishing exercise:", error);
      this.hideLoading();
      alert("Failed to save your exercise. Please try again.");
    }
  }

  disconnect() {
    this.stop();
    // 清理事件监听器
    window.removeEventListener("beforeunload", this.addBeforeUnloadListener);
  }

  generatePhasesBreakdown() {
    const breakdown = {
      total_duration: this.currentTime,
      cycles_completed: this.currentCycle - 1,
      phases_per_cycle: 3,
      total_phases: (this.currentCycle - 1) * 3,
      phase_durations: {
        inhale: 4,
        hold: 4,
        exhale: 6,
      },
      completion_percentage: (((this.currentCycle - 1) / 5) * 100).toFixed(1),
      timestamp: new Date().toISOString(),
    };

    return JSON.stringify(breakdown);
  }

  showPointsEarned(points) {
    // 创建积分获得提示
    const notification = document.createElement("div");
    notification.className =
      "fixed top-4 right-4 bg-yellow-100 border border-yellow-400 text-yellow-800 px-4 py-3 rounded-lg shadow-lg z-50";
    notification.innerHTML = `
      <div class="flex items-center">
        <svg class="h-5 w-5 text-yellow-600 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path>
        </svg>
        <span class="font-semibold">+${points} Calm Points earned!</span>
      </div>
    `;

    document.body.appendChild(notification);

    // 3秒后自动移除
    setTimeout(() => {
      notification.remove();
    }, 3000);
  }

  showLoading() {
    this.loadingOverlayTarget.classList.remove("hidden");
  }

  hideLoading() {
    this.loadingOverlayTarget.classList.add("hidden");
  }
}
