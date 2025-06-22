using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class ChangeSince : MonoBehaviour
{
    public string Map;

    void Awake()
    {
        GetComponent<Button>().onClick.AddListener(CSince);
    }

    void CSince()
    {
        SceneManager.LoadScene(Map);
    }
}
