using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UFO : MonoBehaviour
{
    private GameObject _UFOSpinner;
    private LevelManager _lm;
    public Vector3 checkCubePos = new Vector3(0f, 4f, 0f);
    public Vector3 checkCubeExt = new Vector3(4f, 4f, 4f);
    public Vector3 startPos;
    public Vector3 endPos;
    [Range(0,1)]
    public float sliderSoundVolume;
    public float spawnTimer = 10f;
    public GameObject grayPrefab;
    public Gray currentGray;
    public float timeLimit;
    public float timer;
    public bool spawning = false;


    private void Start()
    {
        _UFOSpinner = GameObject.Find("UFOSpinner");
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        GameVars.Values.soundManager.PlaySound("UFOBuzz", sliderSoundVolume, true, 1f);
    }

    public void RotateUFOSpinner()
    {
        _UFOSpinner.transform.Rotate(new Vector3(0f,0f,180f * Time.deltaTime));
    }

    private void Update()
    {
        RotateUFOSpinner();
        if (currentGray != null) SpawnGreyLerp();
        if (timer >= timeLimit)
        {
            currentGray.AwakeGray();
            currentGray = null;
            timer = 0;
        }
    }

    public void BeginSpawn()
    {
        spawning = true;
        StartCoroutine("SpawnGrey");
    }

    IEnumerator SpawnGrey()
    {
        yield return new WaitForSeconds(spawnTimer);
        if (_lm.canSpawn && !Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
        {
            currentGray = Instantiate(grayPrefab, transform.position - startPos, Quaternion.identity).GetComponent<Gray>();
            _lm.EnemySpawned();
            spawning = false;
        }
        else StartCoroutine("SpawnGrey");
    }

    public void SpawnGreyLerp()
    {
        currentGray.SetPos(Vector3.Lerp(transform.position - startPos, transform.position - endPos, timer / timeLimit));
        timer += Time.deltaTime;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position - checkCubePos, checkCubeExt);
        Gizmos.DrawWireCube(transform.position - startPos, new Vector3(0.5f, 0.5f, 0.5f));
        Gizmos.DrawWireCube(transform.position - endPos, new Vector3(0.5f, 0.5f, 0.5f));
    }
}
