using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TheWorld : MonoBehaviour
{
    private Material TimeStop;
    public Button btn;
    bool IsStop = false;
    bool IsChange = false;
    public float Change_Speed = 1;
    float R;
    public Animator jojo;
    void Start()
    {
        btn.onClick.AddListener(StopTime);
        TimeStop = GetComponent<Renderer>().material;
        TimeStop.SetFloat("_TimeStop_R", 0);
    }

    void Update()
    {
        if (IsChange)
        {
            if (IsStop)
            {
                R += Time.deltaTime * Change_Speed;
                TimeStop.SetFloat("_TimeStop_R", R);
                if (R > 10)
                {
                    IsChange = false;
                }
            }
            else
            {
                R -= Time.deltaTime * Change_Speed;
                TimeStop.SetFloat("_TimeStop_R", R);
                if (R <= 0.1f)
                {
                    jojo.speed = 1;
                    TimeStop.SetFloat("_TimeStop_R", 0);
                    IsChange = false;
                }
            }
        }
    }

    public void StopTime()
    {
        IsStop = !IsStop;
        IsChange = true;
        jojo.speed = 0;
        if (IsStop)
        {
            btn.GetComponentInChildren<TextMeshProUGUI>().text = "Start";
        }
        else
        {
            btn.GetComponentInChildren<TextMeshProUGUI>().text = "Stop";
        }
    }
}
