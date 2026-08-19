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

    public Material brushMat;

    
    void Start()
    {
        Graphics.Blit(initHight, rt);

        if(brushMat != null)
        {
            brushMat.SetTexture("Texture2D", brush);
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out RaycastHit hit))
            {
                // ��ȡ������� UV ���� (0-1)
                Vector2 uv = hit.textureCoord;
                // ת���� RT �ϵ���������
                int x = (int)(uv.x * rt.width);
                // ע�⣺UV��Y���ͼ�λ���API��Y�᷽���෴����Ҫ��ת
                int y = (int)(rt.height - uv.y * rt.height);

                // ������ִ�л��Ʋ���...
                Draw(x, y);
            }
        }
    }

    private void Draw(int x, int y)
    {
        // ���û��Ƶ�Ŀ��Ϊ rt
        RenderTexture.active = rt;
        // ���þ����Ա��������������
        GL.LoadPixelMatrix(0, rt.width, rt.height, 0);

        // ������������ñ�ˢ���Ķ�׼�����
        int brushSize = brush.width;
        Rect rect = new Rect(x - brushSize / 2, y - brushSize / 2, brushSize, brushSize);
        // �� Graphics.DrawTexture ���ϱ�ˢ����
        Graphics.DrawTexture(rect, brush);

        // ���ã���Ӧ���޸�
        RenderTexture.active = null;
    }
}
