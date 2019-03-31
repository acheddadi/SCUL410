using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicController : MonoBehaviour
{
    [SerializeField] private DontDestroy music;
    private void Awake()
    {
        DontDestroy dontDestroy = FindObjectOfType<DontDestroy>();
        if (dontDestroy == null)
        {
            Instantiate(music);
        }
    }
}
