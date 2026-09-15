using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoidsManager3D : MonoBehaviour
{
    public GameObject boidPrefab;
    public static BoidsManager3D instance;

    //区域范围
    public float areaLength = 2f;
    public float areaWidth = 2f;
    public float areaHeight = 2f;

    //生成
    public float boidSpeed = 2f;
    public int boidsNum = 10;

    //boids行为相关
    public float boidViewDst = 2f;
    public float boidViewDstConhension = 2f;
    public float boidViewDstSeparate = 0.5f;
    [Range(0f, 180f)]
    public float boidViewAngle = 180f;
    public float boidTurnSpeedMax = 60f;
    public float nearestDst = 0.2f;

    [Range(0f, 1f)]
    public float separateScale = 1;
    [Range(0f, 1f)]
    public float alignScale = 1;
    [Range(0f, 1f)]
    public float cohensionScale = 1;

    //暴露统一边界参数
    public float minY;
    public float maxY;
    public float minX;
    public float maxX;
    public float minZ;
    public float maxZ;

    public System.Collections.Generic.List<GameObject> boidsList = new();

    void Awake()
    {
        instance = this;
    }
    void Start()
    {
        CreateBoids(true);
    }

    void Update()
    {
        UpdateBounds();
    }


    private void OnDrawGizmos()
    {
        UpdateBounds();

        Gizmos.color = Color.green;

        // 8 个顶点
        Vector3 p000 = new Vector3(minX, minY, minZ);
        Vector3 p100 = new Vector3(maxX, minY, minZ);
        Vector3 p110 = new Vector3(maxX, maxY, minZ);
        Vector3 p010 = new Vector3(minX, maxY, minZ);

        Vector3 p001 = new Vector3(minX, minY, maxZ);
        Vector3 p101 = new Vector3(maxX, minY, maxZ);
        Vector3 p111 = new Vector3(maxX, maxY, maxZ);
        Vector3 p011 = new Vector3(minX, maxY, maxZ);

        // 前面 (Z = minZ)
        Gizmos.DrawLine(p000, p100);
        Gizmos.DrawLine(p100, p110);
        Gizmos.DrawLine(p110, p010);
        Gizmos.DrawLine(p010, p000);

        // 后面 (Z = maxZ)
        Gizmos.DrawLine(p001, p101);
        Gizmos.DrawLine(p101, p111);
        Gizmos.DrawLine(p111, p011);
        Gizmos.DrawLine(p011, p001);

        // 连接前后
        Gizmos.DrawLine(p000, p001);
        Gizmos.DrawLine(p100, p101);
        Gizmos.DrawLine(p110, p111);
        Gizmos.DrawLine(p010, p011);
    }

    void CreateBoids(bool randomRotation)
    {

        for (int i = 0; i < boidsNum; i++)
        {
            // 1. 本地坐标随机撒点
            float x = Random.Range(minX, maxX);
            float y = Random.Range(minY, maxY);
            float z = Random.Range(minZ, maxZ);
            Vector3 localPos = new Vector3(x, y, z);

            // 2. 转成世界坐标（这样即使父物体移动/旋转也正确）
            Vector3 worldPos = transform.TransformPoint(localPos);

            // 3. 随机朝向（2D只在Z轴旋转）
            Quaternion rot = Random.rotation;

            // 4. 生成
            GameObject go = Instantiate(boidPrefab, worldPos, rot, transform);
            boidsList.Add(go);
        }
    }

    void UpdateBounds()
    {
        Vector3 center = transform.position;

        minX = center.x - areaWidth / 2f;
        maxX = center.x + areaWidth / 2f;

        minY = center.y - areaHeight / 2f;
        maxY = center.y + areaHeight / 2f;

        minZ = center.z - areaLength / 2f;
        maxZ = center.z + areaLength / 2f;
    }
}
