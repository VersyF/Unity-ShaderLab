using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class Boid2_CreateBoids : MonoBehaviour
{
    public static Boid2_CreateBoids instance;               //单例模式

    public Vector2 topLeft = new Vector2(-1, 1);
    public Vector2 bottomRight = new Vector2(1, -1);

    public GameObject boidPrefab;

    public int boidsNum = 10;

    public System.Collections.Generic.List<GameObject> boidsList = new();

    // Start is called before the first frame update
    void Start()
    {
        instance = this;
        if (boidPrefab != null)
        {
            CreateBoids(-0.5f, true);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void CreateBoids(float zPosition, bool randomRotation)
    {
        // 计算矩形范围（本地坐标，注意 topLeft.x 可能大于 bottomRight.x）
        float minX = Mathf.Min(topLeft.x, bottomRight.x);
        float maxX = Mathf.Max(topLeft.x, bottomRight.x);
        float minY = Mathf.Min(topLeft.y, bottomRight.y);
        float maxY = Mathf.Max(topLeft.y, bottomRight.y);

        for (int i = 0; i < boidsNum; i++)
        {
            // 1. 本地坐标随机撒点
            float x = Random.Range(minX, maxX);
            float y = Random.Range(minY, maxY);
            Vector3 localPos = new Vector3(x, y, zPosition);

            // 2. 转成世界坐标（这样即使父物体移动/旋转也正确）
            Vector3 worldPos = transform.TransformPoint(localPos);

            // 3. 随机朝向（2D只在Z轴旋转）
            Quaternion rot = Quaternion.identity;
            if (randomRotation)
            {
                float angle = Random.Range(0f, 360f);
                rot = Quaternion.Euler(0f, 0f, angle);
            }

            // 4. 生成
            GameObject go = Instantiate(boidPrefab, worldPos, rot, transform);
            boidsList.Add(go);
        }
    }

    private void OnDrawGizmos()
    {
        // 世界坐标（假设脚本挂在物体上，把本地坐标转成世界坐标）
        Vector3 tl = transform.TransformPoint(new Vector3(topLeft.x, topLeft.y, 0));
        Vector3 br = transform.TransformPoint(new Vector3(bottomRight.x, bottomRight.y, 0));
        Vector3 tr = new Vector3(br.x, tl.y, tl.z);
        Vector3 bl = new Vector3(tl.x, br.y, tl.z);

        Gizmos.color = Color.green;
        Gizmos.DrawLine(tl, tr);
        Gizmos.DrawLine(tr, br);
        Gizmos.DrawLine(br, bl);
        Gizmos.DrawLine(bl, tl);

        // 两个角点
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(tl, 0.08f);
        Gizmos.DrawSphere(br, 0.08f);
    }
}
