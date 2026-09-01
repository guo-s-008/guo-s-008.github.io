# 银途输入输出案例（演示数据）

> 以下为用于展示产品链路的合成输入和演示岗位结果，不是真实用户、真实岗位或真实就业结果。字段和处理方式依据当前代码实现整理。

## 输入

“以前在食堂做过几年，会备菜和打饭，希望找白班，不能长时间搬重物。”

## 处理过程

1. 文本可直接调用 `/api/voice/recognize-text`，也可以先经语音识别后进入同一 Agent。
2. `dispatch` 判断信息完整度；不足 0.6 时由 `collect_info` 继续追问。
3. `ability_card_service.py` / `collect_node.py` 使用 LLM 结构化抽取，并对明确出现的“备菜、打饭、白班、不能长时间搬重物”做规则补齐。
4. 用户确认能力卡后，系统生成版本号并写入确认时间和审计记录。

## 能力卡输出（示例）

```json
{
  "skills": ["备菜", "分餐"],
  "experience": "有食堂工作经历（具体年限待补充）",
  "constraints": ["白班", "避免长时间搬重物"],
  "preferred_jobs": ["食堂辅助", "后勤服务"],
  "available_hours": "未填写",
  "location": "未填写",
  "status": "draft"
}
```

注意：输入没有明确给出服务沟通、工作地点、可工作时长或具体年限，因此不能自行补充这些事实。正式能力卡还会包含姓名、年龄、身体状况、通勤、开始时间和培训意愿等字段，未提及字段保持“未填写”。

## 系统结果（演示岗位）

| 岗位 | 匹配/风险展示 | 理由或提醒 |
|---|---|---|
| 社区食堂帮厨（演示） | 高匹配示例；低风险可申请 | 工作内容包含备菜、分餐；固定白班；可安排休息；仍需确认具体站立时长 |
| 社区活动协理员（演示） | 中风险，需要确认 | 沟通经验可能相关；活动日存在连续走动，需确认体力和通勤 |
| 厂区夜间门卫（演示） | 高风险/不建议 | 包含夜班、12 小时轮班、长时间站立，与“白班、避免重物/长工时”边界冲突 |
| 居家手工包装员（风险演示） | blocked，申请拦截 | 要求先交培训费、材料押金和身份证照片 |

## 代码依据

- 能力卡抽取与明确事实补齐：`F:\trae创意\yintu-opc\backend\app\services\ability_card_service.py`
- 多轮收集与完整度：`F:\trae创意\yintu-opc\backend\app\agent\collect_node.py`
- Embedding/余弦匹配：`F:\trae创意\yintu-opc\backend\app\services\match_service.py`、`match_node.py`
- 风险等级与申请拦截：`F:\trae创意\yintu-opc\backend\app\services\risk_service.py`、`routers/applications.py`
- 演示岗位：`F:\trae创意\yintu-opc\backend\app\seed.py`
