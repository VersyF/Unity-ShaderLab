using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SF_DrawHeighMap : MonoBehaviour
{
    // Start is called before the first frame update
    public RenderTexture rt;
    public Texture2D initHight;
    public Texture2D brush;

    
    void Start()
    {
        Graphics.Blit(initHight, rt);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                // 获取点击处的 UV 坐标 (0-1)
                Vector2 uv = hit.textureCoord;
                // 转换成 RT 上的像素坐标
                int x = (int)(uv.x * rt.width);
                // 注意：UV的Y轴和图形绘制API的Y轴方向相反，需要翻转
                int y = (int)(rt.height - uv.y * rt.height);

                // 在这里执行绘制操作...
                Draw(x, y);
            }
        }
    }

    private void Draw(int x, int y)
    {
        // 设置绘制的目标为 rt
        RenderTexture.active = rt;
        // 重置矩阵，以便用像素坐标绘制
        GL.LoadPixelMatrix(0, rt.width, rt.height, 0);

        // 计算绘制区域，让笔刷中心对准点击点
        int brushSize = brush.width;
        Rect rect = new Rect(x - brushSize / 2, y - brushSize / 2, brushSize, brushSize);
        // 用 Graphics.DrawTexture 画上笔刷纹理
        Graphics.DrawTexture(rect, brush);

        // 重置，并应用修改
        RenderTexture.active = null;
    }
}
