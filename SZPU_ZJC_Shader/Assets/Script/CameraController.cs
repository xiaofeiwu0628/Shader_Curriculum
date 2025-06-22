using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    #region ����ģʽ
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
    #region ʹ�õ��������
    public Transform initialposition;
    [SerializeField]private Transform target;

    private Transform cam;
    #endregion
    #region ʹ�õĲ���
    // ��ȡ����X��Y���ֵ
    private float mouseX;
    private float mouseY;
    // ������ת���ٶ�
    public float rotateSpeedX = 3f;
    public float rotateSpeedY = 3f;
    // ���ɿ���
    public float lerpSpeed = 0.5f;

    // �����ƶ��ľ���
    public float minDistance;
    public float maxDistance;
    // ������תֵ�Ĵ�С
    public float minRotateYClampValue = -45;
    public float maxRotateYClampValue = 60;
    // ��������Ƿ�������ת��λ��
    [Header("�Ƿ�������ת��λ��")]
    [SerializeField]private bool isChange = true;
    [Header("λ�ƾ���")]
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
    /// ��Ҫ�����ı����
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

        // �ı����ʹ�䷢���ı��
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
    /// ��Ҫִ�в����仯�����������
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
    /// ��ȡ����Ŀǰ��λ��
    /// </summary>
    private float GetCurrentPos()
    {
        return minDistance + (maxDistance - minDistance) * distanceScaleValue;
    }

    #region �ⲿ���øı����
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

    #region �ⲿ���ú���
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
