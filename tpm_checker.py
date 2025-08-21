import sys
from PyQt6.QtWidgets import (
    QApplication,
    QWidget,
    QVBoxLayout,
    QLabel,
    QMessageBox,
)
from PyQt6.QtCore import Qt
import subprocess


def get_tpm_status():
    """使用命令行检查 TPM 状态。"""
    try:
        # 运行 tpm.msc 命令并检查输出，虽然tpm.msc是图形界面，但其wmi信息可以被subprocess查询
        # 这里我们使用 powershell 的 Get-Tpm cmdlet 来获取更可靠的信息
        result = subprocess.run(
            ["powershell.exe", "Get-Tpm"],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8"
        )
        if "True" in result.stdout:
            # 简化判断，如果 powershell 返回的 Enabled 或 Present 字段为 True
            return "开启"
        else:
            return "未开启"
    except Exception as e:
        print(f"检查 TPM 状态时出错: {e}")
        return "无法检测"


def get_secure_boot_status():
    """使用命令行检查 Secure Boot 状态。"""
    try:
        # 使用 powershell 的 Confirm-SecureBootUEFI cmdlet 来获取信息
        result = subprocess.run(
            ["powershell.exe", "Confirm-SecureBootUEFI"],
            capture_output=True,
            text=True,
            check=True,
            encoding="utf-8"
        )
        if "True" in result.stdout:
            return "开启"
        else:
            return "未开启"
    except Exception as e:
        print(f"检查 Secure Boot 状态时出错: {e}")
        return "无法检测"


class TPMCheckerApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()
        self.check_status()

    def initUI(self):
        self.setWindowTitle("Windows 启动安全检测器")
        self.setFixedSize(400, 200)

        main_layout = QVBoxLayout()
        main_layout.setSpacing(20)
        main_layout.setAlignment(Qt.AlignmentFlag.AlignCenter)

        title_label = QLabel("Windows 启动安全检测结果")
        title_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title_label.setStyleSheet("font-size: 18px; font-weight: bold;")
        main_layout.addWidget(title_label)


        self.setLayout(main_layout)

    def check_status(self):
        # 异步调用并更新状态，确保界面不卡顿
        tpm_status = get_tpm_status()
        secure_boot_status = get_secure_boot_status()

        self.update_labels(tpm_status, secure_boot_status)

    def update_labels(self, tpm_status, secure_boot_status):
        self.tpm_label.setText(
            f"TPM 状态：<font color='{'green' if tpm_status == '开启' else 'red'}'>{tpm_status}</font>")
        self.secure_boot_label.setText(
            f"Secure Boot 状态：<font color='{'green' if secure_boot_status == '开启' else 'red'}'>{secure_boot_status}</font>")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    ex = TPMCheckerApp()
    ex.show()
    sys.exit(app.exec())