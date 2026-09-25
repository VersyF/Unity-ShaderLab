using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GT_TransDataToComputeShader : MonoBehaviour
{
    [SerializeField]
    public ComputeShader computeShader;
    public int resolution = 64;
    public float grassSpacing = 1;
    [SerializeField, Range(0,2)]
    public float randomPosition = 0;

    private static readonly int
        resolutionID = Shader.PropertyToID("_Resolution"),                  //通过提前取哈希值，避免了每帧调用时自动取哈希值，节省开销
        grassSpacingID = Shader.PropertyToID("_GrassSpacing"),
        randomPositionID = Shader.PropertyToID("_Random");

    Mesh mesh;

    private ComputeBuffer outputBuffer;
    private ComputeBuffer colorBuffer;
    private ComputeBuffer trianglesBuffer;
    int kernel;

    [SerializeField]
    Material material;
    Bounds bounds;
    ComputeBuffer argsBuffer;
    int[] args = new int[]{
            21, 0, 0, 0
        };

    MaterialPropertyBlock properties;

    private void Awake()
    {
        bounds = new Bounds(new Vector3(0, 0, 0), new Vector3(1000, 1000, 1000));
        mesh = GrassMesh.CreateHighLodGrass();
    }
    void Start()
    {
        kernel = computeShader.FindKernel("CSMain");
        InitializeComputeBuffer();
        InitializeComputeShader();
        InitializeShader();
    }
    void Update()
    {
        UpdateComputeShaderParameter();
        UpdateGPUOutput();
        RenderGrass();
    }
    private void OnDestroy()
    {
        DisposeBuffers();
    }


    //初始化Buffer
    //开辟大小，设置模式，重置计数
    private void InitializeComputeBuffer()
    {
        outputBuffer = new ComputeBuffer(resolution * resolution, sizeof(float) * 3, ComputeBufferType.Append);
        outputBuffer.SetCounterValue(0);
        //间接索引buffer
        argsBuffer = new ComputeBuffer(1, sizeof(int) * 4, ComputeBufferType.IndirectArguments);
        argsBuffer.SetData(args);
        //ColorBuffer 、TrianglesBuffer
        colorBuffer = new ComputeBuffer(mesh.colors.Length, sizeof(float) * 4);  //?
        trianglesBuffer = new ComputeBuffer(mesh.triangles.Length, sizeof(int));

        colorBuffer.SetData(mesh.colors);
        trianglesBuffer.SetData(mesh.triangles);
    }
    //初始化ComputeShader - 绑定buffer
    private void InitializeComputeShader()
    {
        computeShader.SetBuffer(kernel, "outputBuffer", outputBuffer);
        
    }
    //传入shader
    protected void InitializeShader()
    {
        material.SetBuffer("_GrassBladeBuffer", outputBuffer);
        material.SetBuffer("_ColorBuffer", colorBuffer);
        material.SetBuffer("_TrianglesBuffer", trianglesBuffer);
    }
    //更新CS传入数据
    private void UpdateComputeShaderParameter()
    {
        computeShader.SetInt(resolutionID, resolution);
        computeShader.SetFloat(grassSpacingID, grassSpacing);
        computeShader.SetFloat(randomPositionID, randomPosition);
    }
    //更新GPU输出
    private void UpdateGPUOutput()
    {
        outputBuffer.SetCounterValue(0);

        int threadGroupX = Mathf.CeilToInt(resolution / 8f);
        int threadGroupZ = Mathf.CeilToInt(resolution / 8f);

        computeShader.Dispatch(kernel, threadGroupX, threadGroupZ, 1);
    }
    //更新渲染草
    void RenderGrass()
    {
        ComputeBuffer.CopyCount(outputBuffer, argsBuffer, sizeof(int));

        Graphics.DrawProceduralIndirect(material, bounds, MeshTopology.Triangles, argsBuffer,
                                                                0, null, null, UnityEngine.Rendering.ShadowCastingMode.Off, true, gameObject.layer);
    }
    
    
    //释放所有Buffers
    private void DisposeBuffers()
    {
        DisposeBuffer(outputBuffer);
        DisposeBuffer(argsBuffer);
        DisposeBuffer(colorBuffer);
        DisposeBuffer(trianglesBuffer);
    }
    //释放 某个 Buffer
    private void DisposeBuffer(ComputeBuffer buffer)
    {
        if (buffer != null)
        {
            buffer.Release();
        }
    }
}
