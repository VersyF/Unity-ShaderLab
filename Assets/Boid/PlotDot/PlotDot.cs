using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlotDot : MonoBehaviour
{
    public int dotNum = 10;
    [Range(0f, 1f)]
    public float angleOff = 0;
    public float dotDst = 0.2f;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        

    }

    private void OnDrawGizmos()
    {
        DrawGraph();
    }

    void DrawGraph()
    {
        for (int i = 0; i < dotNum; i++)
        {
            float dst = i * dotDst;
            float angle = angleOff * i;
            float x = Mathf.Cos(angle) * dst;
            float y = Mathf.Sin(angle) * dst;
            AddDot(new Vector2(x, y));
        }
    }

    void AddDot(Vector2 axis)
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(new Vector3(axis.x, axis.y, 0f), 0.1f);
    }
}
