using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoopController : MonoBehaviour
{
    private void OnEnable()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
