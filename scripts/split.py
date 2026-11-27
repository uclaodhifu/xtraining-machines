# 每类 80% 训练、20% 测试；不到 8 张的器械先不训练
import os, random, shutil
random.seed(7); shutil.rmtree("build", ignore_errors=True)
skipped = []
for c in sorted(os.listdir("照片")):
    d = f"照片/{c}"
    if not os.path.isdir(d): continue
    fs = [f for f in os.listdir(d) if f.lower().endswith((".jpg", ".jpeg", ".png", ".heic"))]
    if len(fs) < 8: skipped.append(f"{c}（{len(fs)} 张）"); continue
    random.shuffle(fs); k = max(2, len(fs) // 5)
    for part, ns in (("test", fs[:k]), ("train", fs[k:])):
        os.makedirs(f"build/{part}/{c}", exist_ok=True)
        for n in ns: shutil.copy(f"{d}/{n}", f"build/{part}/{c}/{n}")
    print(c, "训练", len(fs) - k, "测试", k)
os.makedirs("模型", exist_ok=True)
open("build/skipped.txt", "w").write("、".join(skipped))
