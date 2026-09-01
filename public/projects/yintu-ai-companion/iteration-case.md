# 银途一次真实迭代案例

## 案例 A：移动端录音/TTS 受权限、HTTPS 和自动播放策略影响

- 发现问题：代码审查记录指出，移动浏览器在 HTTP、未授权录音场景或未满足自动播放策略时，录音/TTS 不能稳定工作。
- 判断原因：浏览器 `getUserMedia`、`MediaRecorder`、AudioContext 和语音引擎都受浏览器能力、安全上下文和用户手势限制；不同浏览器对音频编码支持也不一致。
- 当前处理：`audioRecorder.js` 增加浏览器能力检测、录音流停止、WebM 解码为 16kHz PCM16 和手动输入降级；store 的 TTS 增加 `resume()` 和中文 voice 优先选择。开发日志记录该修复，前端测试、E2E 和视口检查通过。
- 尚未解决的边界：没有真实 iOS/Android/微信浏览器矩阵；正式演示仍需 HTTPS；TTS 仍依赖浏览器语音引擎，不能宣称所有设备稳定播放。
- 证据：`F:\trae创意\yintu-opc\development-logs\review-log.md` 的 R-003/R-004，`module-log.md` 2026-08-16 14:14，`frontend/src/services/audioRecorder.js`。

## 案例 B：空回答或过短回答可能得到默认正向评分

- 发现问题：面试回答接口没有空值/长度校验；当评分 LLM 解析失败或服务异常时，代码会返回逐题 10/20 分和总结 70/100 的鼓励文案。
- 判断原因：当前评分 Prompt 只规定“答非所问”的分档，没有独立的输入质量门槛；异常兜底优先保证流程可继续，但会产生过度正向反馈风险。
- 当前处理：已保留结构化评分、分数范围截断和异常日志；Prompt 明确 0-5 分对应答非所问。项目测试覆盖正常流程，但未覆盖空/过短/无意义回答识别率。
- 尚未解决的边界：未找到已完成的专门修复或测试结果。后续需要增加空/短/偏题识别、追问或保守评分，避免固定正向默认分。
- 证据：`F:\trae创意\yintu-opc\backend\app\services\interview_service.py`、`routers/interviews.py`；`development-logs/test-log.md`。
