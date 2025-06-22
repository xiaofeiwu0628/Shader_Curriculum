using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    #region 单例模式
    public static CameraController instance;
    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            if (instance != this)
            {
                Destroy(gameObject);
            }
        }
    }
    #endregion
    #region 使用到物体对象
    public Transform initialposition;
    [SerializeField]private Transform target;

    private Transform cam;
    #endregion
    #region 使用的参数
    // 获取鼠标的X和Y轴的值
    private float mouseX;
    private float mouseY;
    // 控制旋转的速度
    public float rotateSpeedX = 3f;
    public float rotateSpeedY = 3f;
    // 过渡快慢
    public float lerpSpeed = 0.5f;

    // 限制移动的距离
    public float minDistance;
    public float maxDistance;
    // 限制旋转值的大小
    public float minRotateYClampValue = -45;
    public float maxRotateYClampValue = 60;
    // 控制这个是否允许旋转和位移
    [Header("是否允许旋转和位移")]
    [SerializeField]private bool isChange = true;
    [Header("位移距离")]
    [SerializeField] private float distanceScaleValue;
    #endregion

    void Start()
    {
        cam = Camera.main.transform;
        Vector3 localPos = Quaternion.Inverse(cam.rotation) * cam.position;
        float initialDistance = -localPos.z;
        distanceScaleValue = 0.5f;
        mouseX = cam.eulerAngles.y;
        mouseY = cam.eulerAngles.x;
        target = initialposition;
    }
    /// <summary>
    /// 主要用来改变参数
    /// </summary>
    void Update()
    {
        if (cam != Camera.main.transform)
        {
            cam = Camera.main.transform;
            Vector3 localPos = Quaternion.Inverse(cam.rotation) * cam.position;
            float initialDistance = localPos.z;
            distanceScaleValue = Mathf.Clamp01((initialDistance - minDistance) / (maxDistance - minDistance));
            mouseX = cam.eulerAngles.y;
            mouseY = cam.eulerAngles.x;
        }

        if (!isChange)
        {
            return;
        }

        // 改变参数使其发生改变的
        if (Input.GetMouseButton(1))
        {
            mouseX += Input.GetAxis("Mouse X") * rotateSpeedX;
            mouseY -= Input.GetAxis("Mouse Y") * rotateSpeedY;
            mouseY = Mathf.Clamp(mouseY, minRotateYClampValue, maxRotateYClampValue);
        }
        else if (Input.GetAxis("Mouse ScrollWheel") != 0)
        {
            distanceScaleValue -= Input.GetAxis("Mouse ScrollWheel");
            distanceScaleValue = Mathf.Clamp01(distanceScaleValue);
        }
    }
    /// <summary>
    /// 主要执行参数变化对物体的作用
    /// </summary>
    void LateUpdate()
    {
        Quaternion targetRotation = Quaternion.Euler(mouseY, mouseX, 0);
        cam.rotation = Quaternion.Lerp(targetRotation, cam.rotation, Time.deltaTime * lerpSpeed);
        // transform.rotation = Quaternion.Lerp(targetRotation, transform.rotation, Time.deltaTime * lerpSpeed);

        Vector3 targetPosition = target.position + cam.rotation * new Vector3(0, 0, -GetCurrentPos());
        // Vector3 targetPosition = transfrom.rotation * new Vector3(0, 0, -GetCurrentPos());
        cam.position = Vector3.Lerp(targetPosition, cam.position, Time.deltaTime * lerpSpeed);
        // transform.position = Vector3.Lerp(targetPosition, transform.position, Time.deltaTime * lerpSpeed);
    }
    /// <summary>
    /// 获取物体目前的位置
    /// </summary>
    private float GetCurrentPos()
    {
        return minDistance + (maxDistance - minDistance) * distanceScaleValue;
    }

    #region 外部调用改变参数
    public void SetisChange(bool change = false)
    {
        isChange = change;
    }
    public bool GetisChange()
    {
        return isChange;
    }
    public void SetTarget(Transform _target)
    {
        target = _target;
    }
    #endregion

    #region 外部调用函数
    public void Initialization()
    {
        target = initialposition;
        cam.rotation = Quaternion.Euler(0, 0, 0);
        mouseX = cam.eulerAngles.y;
        mouseY = cam.eulerAngles.x;
        Vector3 localPos = Quaternion.Inverse(cam.rotation) * cam.position;
        float initialDistance = -localPos.z;
        distanceScaleValue = 0.5f;
    }

    #endregion
}
