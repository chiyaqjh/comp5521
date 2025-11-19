from PIL import Image, ImageDraw, ImageFont
import requests
from io import BytesIO

def add_text_to_image(image_url, text, output_path):
    # 下载图片
    response = requests.get(image_url)
    img = Image.open(BytesIO(response.content))
    
    # 创建绘图对象
    draw = ImageDraw.Draw(img)
    
    # 加载字体（确保字体文件存在）
    try:
        font = ImageFont.truetype("arial.ttf", 40)
    except:
        font = ImageFont.load_default()
    
    # 计算文字位置（居中）
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    position = ((img.width - text_width) // 2, img.height - text_height - 20)
    
    # 添加文字背景
    padding = 10
    draw.rectangle([
        position[0] - padding,
        position[1] - padding,
        position[0] + text_width + padding,
        position[1] + text_height + padding
    ], fill="black")
    
    # 添加文字
    draw.text(position, text, font=font, fill="white")
    
    # 保存图片
    img.save(output_path)
    return output_path

# 使用示例
image_url = "https://github.com/chiyaqjh/comp5521/blob/main/images/1.jpg"
text = "COMP5521 NFT Collection"
output_path = "1_with_text.png"

add_text_to_image(image_url, text, output_path)