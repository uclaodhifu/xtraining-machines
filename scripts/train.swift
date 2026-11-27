// 用苹果 Create ML 训练（在苹果自带的看图能力上再学一层，模型很小，手机本地跑）
import CreateML
import Foundation
let params = MLImageClassifier.ModelParameters(
    validation: MLImageClassifier.ModelParameters.ValidationData.split(strategy: .automatic),
    maxIterations: 80,
    augmentation: MLImageClassifier.ImageAugmentationOptions([.crop, .exposure, .flip, .rotation, .blur]))
let trainData = MLImageClassifier.DataSource.labeledDirectories(at: URL(fileURLWithPath: "build/train"))
let testData = MLImageClassifier.DataSource.labeledDirectories(at: URL(fileURLWithPath: "build/test"))
let model = try MLImageClassifier(trainingData: trainData, parameters: params)
let ev = model.evaluation(on: testData)
let f = { (e: Double) in String(format: "%.1f%%", (1 - e) * 100) }
let skipped = (try? String(contentsOfFile: "build/skipped.txt", encoding: .utf8)) ?? ""
var r = "训练时间：\(Date())\n\n"
r += "没见过的照片上的准确率：\(f(ev.classificationError))   ← 主要看这个\n"
r += "训练照片上：\(f(model.trainingMetrics.classificationError))，验证：\(f(model.validationMetrics.classificationError))\n\n"
if !skipped.isEmpty { r += "照片太少（不到 8 张）暂时没训练：\(skipped)\n\n" }
r += "每种器械（precision = 认成它时对的比例，recall = 它被认出来的比例）：\n\(ev.precisionRecall)\n\n容易认混的（行 = 实际，列 = 认成）：\n\(ev.confusion)\n"
try r.write(toFile: "模型/准确率报告.txt", atomically: true, encoding: .utf8)
try model.write(to: URL(fileURLWithPath: "模型/MachineClassifier.mlmodel"), metadata: MLModelMetadata(author: "X Training", shortDescription: "健身器械类型识别", version: "1"))
print(r)
