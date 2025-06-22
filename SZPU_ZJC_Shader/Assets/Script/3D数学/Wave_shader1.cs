using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class Wave_shader1 : MonoBehaviour
{
    public int waveWidth = 128;
    public int waveHeight = 128;
    float[,] waveA;
    float[,] waveB;
    public int r = 1;//水波的范围



    Texture2D tex_uv;
    void Start()
    {
        waveA = new float[waveWidth, waveHeight];
        waveB = new float[waveWidth, waveHeight];

        tex_uv = new Texture2D(waveWidth, waveHeight);

        GetComponent<Renderer>().material.SetTexture("_MainTex", tex_uv);
    }
    void Update()
    {
        ComputeWave();
        if (Input.GetMouseButton(0))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out hit))
            {
                Vector3 pos = transform.worldToLocalMatrix.MultiplyPoint(hit.point);

                int w = (int)((pos.x + 0.5) * waveWidth);
                int h = (int)((pos.y + 0.5) * waveHeight);
                PutDrop(w, h);
            }
        }
    }

    void ComputeWave()
    {
            for (int w = 1; w < waveWidth - 1; w++)
            {
                for (int h = 1; h < waveHeight - 1; h++)
                {
                    waveB[w, h] = (
                        waveA[w - 1, h] +
                        waveA[w + 1, h] +
                        waveA[w, h - 1] +
                        waveA[w, h + 1] +
                        waveA[w + 1, h + 1] +
                        waveA[w + 1, h - 1] +
                        waveA[w - 1, h - 1] +
                        waveA[w - 1, h + 1]) / 4 - waveB[w, h];

                    float value = waveB[w, h];
                    if (value > 1) waveB[w, h] = 1;

                    if (value < -1) waveB[w, h] = -1;

                    float offset_u = (waveB[w - 1, h] - waveB[w + 1, h]) / 2;
                    float offset_v = (waveB[w, h - 1] - waveB[w, h + 1]) / 2;

                    float r = offset_u / 2 + 0.5f;
                    float g = offset_v / 2 + 0.5f;



                    tex_uv.SetPixel(w, h, new Color(r, g, 0));

                    waveB[w, h] -= waveB[w, h] * 0.025f;//迭代值
                }
            }

            tex_uv.Apply();

            float[,] temp = waveA;
            waveA = waveB;
            waveB = temp;

    }

    void PutDrop(int x, int y)
    {
        int radius = r;
        float dist;

        for (int i = -radius; i <= radius; i++)
        {
            for (int j = -radius; j <= radius; j++)
            {
                if (((x + i >= 0) && (x + i < waveWidth - 1)) && ((y + j >= 0) && (y + j < waveHeight - 1)))
                {
                    dist = Mathf.Sqrt(i * i + j * j);
                    if (dist < radius) waveA[x + i, y + j] = Mathf.Cos(dist * Mathf.PI / radius);
                }
            }
        }
    }
}
