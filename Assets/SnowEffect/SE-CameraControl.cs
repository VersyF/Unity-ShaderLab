using UnityEngine;

public class SECameraControl : MonoBehaviour
{
    [Header("移动设置")]
    [SerializeField] private float moveSpeed = 5f;          // 基础移动速度
    [SerializeField] private float sprintMultiplier = 2f;    // 冲刺速度倍数
    [SerializeField] private float smoothTime = 0.1f;        // 移动平滑时间

    [Header("旋转设置")]
    [SerializeField] private float rotationSpeed = 2f;       // 旋转灵敏度
    [SerializeField] private float minPitchAngle = -80f;     // 最小俯仰角（向下看）
    [SerializeField] private float maxPitchAngle = 80f;      // 最大俯仰角（向上看）

    [Header("参考对象")]
    [SerializeField] private Transform orientationTarget;    // 方向参考物体（可选）

    // 私有变量
    private Vector3 currentVelocity;
    private Vector2 currentRotation;
    private Transform cameraTransform;

    private void Awake()
    {
        cameraTransform = transform;

        // 如果没有指定方向参考物体，则使用相机自身
        if (orientationTarget == null)
        {
            orientationTarget = cameraTransform;
        }

        // 初始化旋转角度
        currentRotation.x = orientationTarget.eulerAngles.y;
        currentRotation.y = orientationTarget.eulerAngles.x;
    }

    private void Update()
    {
        HandleRotation();
        HandleMovement();
    }

    /// <summary>
    /// 处理视角旋转（鼠标右键按住拖动）
    /// </summary>
    private void HandleRotation()
    {
        // 鼠标右键按住时才旋转
        if (Input.GetMouseButton(1))
        {
            // 获取鼠标移动增量
            float mouseX = Input.GetAxis("Mouse X");
            float mouseY = Input.GetAxis("Mouse Y");

            // 更新旋转角度
            currentRotation.x += mouseX * rotationSpeed;
            currentRotation.y -= mouseY * rotationSpeed;
            currentRotation.y = Mathf.Clamp(currentRotation.y, minPitchAngle, maxPitchAngle);

            // 应用旋转
            orientationTarget.rotation = Quaternion.Euler(currentRotation.y, currentRotation.x, 0f);
        }
    }

    /// <summary>
    /// 处理移动（WASD + Shift加速）
    /// </summary>
    private void HandleMovement()
    {
        // 获取输入
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        // 如果没有输入则返回
        if (Mathf.Approximately(horizontal, 0f) && Mathf.Approximately(vertical, 0f))
        {
            return;
        }

        // 计算移动方向（相对于相机的朝向）
        Vector3 moveDirection = orientationTarget.forward * vertical + orientationTarget.right * horizontal;
        moveDirection.y = 0f;                       // 保持水平移动
        moveDirection.Normalize();

        // 计算速度
        float speed = moveSpeed;
        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {
            speed *= sprintMultiplier;
        }

        Vector3 targetPosition = cameraTransform.position + moveDirection * speed * Time.deltaTime;

        // 平滑移动
        cameraTransform.position = Vector3.SmoothDamp(
            cameraTransform.position,
            targetPosition,
            ref currentVelocity,
            smoothTime
        );
    }
}