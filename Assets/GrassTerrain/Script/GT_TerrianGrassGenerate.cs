using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;
using UnityEngine.Rendering;


/// <summary>
/// ComputeShader读取顶点颜色，生成坐标；IndirectDraw；Material接收坐标生成草
/// </summary>
public class GT_TerrianGrassGenerate : MonoBehaviour
{
    [SerializeField, Range(1, 10)]
    float density;
    [SerializeField, Range(0, 1)]
    public float _GrassClip;
    public float Terrain_ClipOffset;
    [SerializeField, Range(0, 0.1f)]
    public float grassWidth = 0.05f;
    [SerializeField, Range(0, 0.5f)]
    public float grassHeight = 0.16f;
    public Color grassColor;
    [SerializeField]    
    public ComputeShader computeShader;         //计算着色器
    public Material mat;                            //渲染草的材质
    public Camera cam;



    //地形 Buffer
    ComputeBuffer TerrainTriangleBuffer;
    ComputeBuffer TerrainVertexBuffer;
    ComputeBuffer TerrainColorBuffer;

    ComputeBuffer outputBuffer;

    //Draw Buffer
    ComputeBuffer ArgsBuffer;
    ComputeBuffer GrassVertexBuffer;
    ComputeBuffer GrassColorBuffer;
    ComputeBuffer GrassTriangleBuffer;

    Mesh terrainMesh;
    Mesh grassMesh;

    int kernel;

    readonly int
        densityID = Shader.PropertyToID("_Density") ,                   //草生长的 密度
        grassClipID = Shader.PropertyToID("_GrassClip"),             //草生长区域的钳制
        localToWorldID = Shader.PropertyToID("_LocalToWorld"),
        terrainVertexBufferID = Shader.PropertyToID("vertexBuffer"),
        terrainColorBufferID = Shader.PropertyToID("colorBuffer"),
        terrainMatrix_VP_ID = Shader.PropertyToID("_VP_Matrix"),
        terrainClipOffsetID = Shader.PropertyToID("_ClipOffset"),
        grassWidthID = Shader.PropertyToID("_GrassWidth"),
        grassHeightID = Shader.PropertyToID("_GrassHeight"),
        grassColorID = Shader.PropertyToID("_GrassColor")
        ;

    [StructLayout(LayoutKind.Sequential)]                   //确保数据按书写排列，不会自动重排
    struct TerrainVertex
    {
        public Vector4 vertex;
        public Vector4 color;
    };
    Vector4[] terrainVertexArr;

    //Draw Grass数据
    int[] argsArr = new int[5]
    {
        0,
        0,
        0,
        0,
        0
    };
    Bounds bounds;

    // Start is called before the first frame update
    void Start()
    {
        bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(1000, 1000, 1000));
        kernel = computeShader.FindKernel("CSMain");                    //找到 核函数
        grassMesh = GetMesh.GetHighLodGrass();
        MeshFilter filter = GetComponent<MeshFilter>();
        terrainMesh = filter.sharedMesh;

        //把vertices转换成float4，方便传入Buffer
        terrainVertexArr = new Vector4[terrainMesh.vertices.Length];
        for (int i = 0; i < terrainMesh.vertices.Length; i++)
        {
            terrainVertexArr[i] = new Vector4(terrainMesh.vertices[i].x, terrainMesh.vertices[i].y, terrainMesh.vertices[i].z, 1);
        }

        InitializeBuffers();
        LinkBuffers();
        if (ArgsBuffer == null)
        {
            Debug.Log("ArgsBuffer is null");
        }
        if (cam == null)
        {
            Debug.Log("Camera is null");
        }
    }

    // Update is called once per frame
    void Update()
    {
       
        UpdateGPUParameter();
        outputBuffer.SetCounterValue(0);
        CSDispatch();

        UpdateArgsBuffer();
        UpdateMaterialParameters();
        DrawGrass();

    }

    private void OnDestroy()
    {
        ReleaseBuffers();
    }

    //初始化Buffer
    void InitializeBuffers()
    {
        ////Terrain 相关 Buffer
        //开辟Buffer
        TerrainVertexBuffer = new ComputeBuffer(terrainMesh.vertices.Length, sizeof(float) * 4);
        TerrainColorBuffer = new ComputeBuffer(terrainMesh.colors.Length, sizeof(float) * 4);
        TerrainTriangleBuffer = new ComputeBuffer(terrainMesh.triangles.Length, sizeof(int));
        outputBuffer = new ComputeBuffer(terrainMesh.triangles.Length, sizeof(float) * 3, ComputeBufferType.Append);

        //填数值
        TerrainVertexBuffer.SetData(terrainVertexArr);
        TerrainColorBuffer.SetData(terrainMesh.colors);
        TerrainTriangleBuffer.SetData(terrainMesh.triangles);

        ////Grass 相关 Buffer
        //开辟Buffer
        GrassVertexBuffer = new ComputeBuffer(grassMesh.vertices.Length, sizeof(float) * 3);
        GrassColorBuffer = new ComputeBuffer(grassMesh.colors.Length, sizeof(float) * 4);
        GrassTriangleBuffer = new ComputeBuffer(grassMesh.triangles.Length, sizeof(int));
        ArgsBuffer = new ComputeBuffer(5, sizeof(int), ComputeBufferType.IndirectArguments);
        //填数值
        GrassVertexBuffer.SetData(grassMesh.vertices);
        GrassColorBuffer.SetData(grassMesh.colors);
        GrassTriangleBuffer.SetData(grassMesh.triangles);

        //ArgsBuffer初始化
        argsArr[0] = grassMesh.triangles.Length;
        ArgsBuffer.SetData(argsArr);
        ArgsBuffer.SetCounterValue(0);
    }

    //更新ArgsBuffer
    void UpdateArgsBuffer()
    {
        if (outputBuffer == null)
        {
            //Debug.LogError("outputBuffer not initialized!");
            return;
        }
        else if (ArgsBuffer == null)
        {
            //Debug.LogError("ArgsBuffer not initialized!");
            return;
        }
        ComputeBuffer.CopyCount(outputBuffer, ArgsBuffer, sizeof(int));
    }
    //更新shader参数
    void UpdateMaterialParameters()
    {
        mat.SetFloat(grassWidthID, grassWidth);
        mat.SetFloat(grassHeightID, grassHeight);
        mat.SetColor(grassColorID, grassColor);
    }
    //绑定Buffer
    void LinkBuffers()
    {
        //ComputeShader Buffer 绑定
        computeShader.SetBuffer(kernel, "vertexBuffer", TerrainVertexBuffer);
        computeShader.SetBuffer(kernel, "colorBuffer", TerrainColorBuffer);
        computeShader.SetBuffer(kernel, "terrainTriangleBuffer", TerrainTriangleBuffer);
        computeShader.SetBuffer(kernel, "outputBuffer", outputBuffer);

        //RenderShader Buffer 绑定
        mat.SetBuffer("VertexBuffer", GrassVertexBuffer);
        mat.SetBuffer("ColorBuffer", GrassColorBuffer);
        mat.SetBuffer("TriangleBuffer", GrassTriangleBuffer);
        mat.SetBuffer("GrassBladeBuffer", outputBuffer);
    }

    //更新 ComputeShader 参数
    void UpdateGPUParameter()    
    {
        TerrainColorBuffer.SetData(terrainMesh.colors);
        computeShader.SetMatrix(localToWorldID, this.transform.localToWorldMatrix);
        computeShader.SetFloat(grassClipID, _GrassClip);

        //视锥体矩阵
        Matrix4x4 matrix_P = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
        Matrix4x4 matrix_V = cam.worldToCameraMatrix;
        computeShader.SetMatrix(terrainMatrix_VP_ID, matrix_P * matrix_V);
        computeShader.SetFloat(terrainClipOffsetID, Terrain_ClipOffset);
    }

    //Dispath
    void CSDispatch()
    {
        int threadGroups = Mathf.CeilToInt(terrainMesh.triangles.Length / 3.0f / 64.0f);      //线程组数 = 三角形数 / 64

        computeShader.Dispatch(kernel, threadGroups, 1, 1);                     //为什么这里每个分量都要设置，是三个维度组数吗
    }

    //绘制
    void DrawGrass()
    {
        Graphics.DrawProceduralIndirect(mat, bounds, MeshTopology.Triangles, ArgsBuffer, 0, null, null, ShadowCastingMode.Off, false, gameObject.layer) ;
    }

    //清理所有Buffer
    void ReleaseBuffers()
    {
        ReleaseBuffer(TerrainVertexBuffer);
        ReleaseBuffer(TerrainTriangleBuffer);

        ReleaseBuffer(outputBuffer);

        ReleaseBuffer(ArgsBuffer);

        ReleaseBuffer(GrassVertexBuffer);
        ReleaseBuffer(GrassColorBuffer);
        ReleaseBuffer(GrassTriangleBuffer);
    }

    //清理某个Buffer
    void ReleaseBuffer(ComputeBuffer computeBuffer) 
    { 
        if(computeBuffer != null)
        {
            computeBuffer.Release();    
        }
    }
}
