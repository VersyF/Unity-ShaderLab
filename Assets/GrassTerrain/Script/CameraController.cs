using UnityEngine;
[ExecuteAlways]
public class CameraController : MonoBehaviour
{
    [Header("移动设置")]
    public float moveSpeed = 5f;           // 移动速度
    public float fastMoveSpeed = 10f;       // 加速移动速度（按住Shift）
    public float rotationSpeed = 3f;        // 旋转灵敏度
    public float verticalSpeed = 3f;        // 垂直升降速度

    [Header("输入设置")]
    public string horizontalAxis = "Horizontal";    // 水平输入轴 (A/D)
    public string verticalAxis = "Vertical";        // 垂直输入轴 (W/S)
    public string mouseXAxis = "Mouse X";           // 鼠标X轴
    public string mouseYAxis = "Mouse Y";           // 鼠标Y轴
    public KeyCode rotateButton = KeyCode.Mouse1;    // 旋转按钮（鼠标右键）
    public KeyCode fastMoveButton = KeyCode.LeftShift; // 加速按钮
    public KeyCode upButton = KeyCode.E;             // 上升按钮
    public KeyCode downButton = KeyCode.Q;           // 下降按钮

    [Header("限制设置")]
    public bool lockCursor = true;           // 是否锁定光标
    public bool invertY = false;              // 是否反转Y轴

    private float rotationX = 0f;
    private float rotationY = 0f;
    private bool isRotating = false;

    void Start()
    {
        // 初始化旋转角度为当前物体的旋转
        Vector3 rot = transform.eulerAngles;
        rotationX = rot.y;      // 绕Y轴旋转（水平）
        rotationY = rot.x;      // 绕X轴旋转（垂直）

        // 锁定光标
        if (lockCursor)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
    }

    void Update()
    {
        HandleRotation();
        HandleMovement();
    }

    void HandleRotation()
    {
        // 检查是否按住鼠标右键
        if (Input.GetKey(rotateButton))
        {
            isRotating = true;

            // 获取鼠标移动
            float mouseX = Input.GetAxis(mouseXAxis) * rotationSpeed;
            float mouseY = Input.GetAxis(mouseYAxis) * rotationSpeed * (invertY ? -1 : 1);

            // 更新旋转角度
            rotationX += mouseX;  // 水平旋转（左右）
            rotationY -= mouseY;  // 垂直旋转（上下）

            // 限制垂直旋转角度（防止翻转）
            rotationY = Mathf.Clamp(rotationY, -90f, 90f);

            // 应用旋转
            transform.rotation = Quaternion.Euler(rotationY, rotationX, 0);

            // 如果光标未锁定，临时隐藏并锁定
            //if (lockCursor && Cursor.lockState != CursorLockMode.Locked)
            //{
            //    Cursor.lockState = CursorLockMode.Locked;
            //    Cursor.visible = false;
            //}
        }
        else
        {
            if (isRotating)
            {
                isRotating = false;

                // 松开右键后，如果lockCursor为true，保持锁定状态
                //if (lockCursor)
                //{
                //    Cursor.lockState = CursorLockMode.Locked;
                //    Cursor.visible = false;
                //}
            }
        }

        // 按ESC解锁光标
        if (Input.GetKeyDown(KeyCode.Escape) && lockCursor)
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
    }

    void HandleMovement()
    {
        // 获取移动输入
        float horizontal = Input.GetAxis(horizontalAxis);  // A/D
        float vertical = Input.GetAxis(verticalAxis);      // W/S

        // 垂直升降 (Q/E)
        float upDown = 0f;
        if (Input.GetKey(upButton))
            upDown = 1f;
        if (Input.GetKey(downButton))
            upDown = -1f;

        // 检查加速
        float currentSpeed = Input.GetKey(fastMoveButton) ? fastMoveSpeed : moveSpeed;

        // 计算移动方向
        Vector3 moveDirection = Vector3.zero;

        // 前后/左右移动基于相机的当前朝向
        if (vertical != 0)
        {
            moveDirection += transform.forward * vertical;
        }
        if (horizontal != 0)
        {
            moveDirection += transform.right * horizontal;
        }

        // 垂直升降基于世界坐标的Y轴
        if (upDown != 0)
        {
            moveDirection += Vector3.up * upDown;
        }

        // 应用移动
        if (moveDirection != Vector3.zero)
        {
            transform.Translate(moveDirection.normalized * currentSpeed * Time.deltaTime, Space.World);
        }
    }

    // 可选：在场景视图中显示一些信息
    void OnGUI()
    {
        if (!lockCursor || Cursor.visible)
        {
            GUILayout.Label("鼠标右键：旋转视角");
            GUILayout.Label("WASD：前后左右移动");
            GUILayout.Label("Q/E：垂直升降");
            GUILayout.Label("Shift：加速");
            GUILayout.Label("ESC：释放光标");
        }
    }
}