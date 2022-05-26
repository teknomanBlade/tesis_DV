using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UFO : MonoBehaviour
{
    private GameObject _UFOSpinner;
    private LevelManager _lm;
    private AudioSource _audioSource;
    public Vector3 checkCubePos = new Vector3(0f, 4f, 0f);
    public Vector3 checkCubeExt = new Vector3(4f, 4f, 4f);
    public Vector3 startPos;
    public Vector3 startPos2;
    public Vector3 startPos3;
    public Vector3 endPos;
    public Vector3 endPos2;
    public Vector3 endPos3;
    [Range(0,1)]
    public float sliderSoundVolume;
    public float spawnTimer = 10f;
    public GameObject grayPrefab;
    public Gray currentGray;
    public Gray currentGray2;
    public Gray currentGray3;
    public float timeLimit;
    public float timer;
    public bool spawning = false;
    private int numberOfWaves;


    private void Start()
    {
        _UFOSpinner = GameObject.Find("UFOSpinner");
        _audioSource = GetComponent<AudioSource>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        GameVars.Values.soundManager.PlaySound(_audioSource, "UFOBuzz", sliderSoundVolume, true, 1f);
    }

    public void RotateUFOSpinner()
    {
        _UFOSpinner.transform.Rotate(new Vector3(0f, 0f, 180f * Time.deltaTime));
    }

    private void Update()
    {
        RotateUFOSpinner();
        if (currentGray != null) SpawnGreyLerp();
        //else if(currentGray != null && numberOfWaves > 5) SpawnGreyLerpTwo();
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
        if(numberOfWaves <= 5)
        {
            StartCoroutine("SpawnGrey");
        }
        else if(numberOfWaves > 5)
        {
            StartCoroutine("SpawnGreyTwo");
        }
       
    }

    IEnumerator SpawnGrey()
    {
        yield return new WaitForSeconds(spawnTimer);
        if (_lm.canSpawn && !Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
        {
            currentGray = Instantiate(grayPrefab, transform.position - startPos, Quaternion.identity).GetComponent<Gray>();
            _lm.EnemySpawned();
            spawning = false;
            numberOfWaves ++;
            Debug.Log(numberOfWaves);
        }
        else StartCoroutine("SpawnGrey");
    }

    IEnumerator SpawnGreyTwo()
    {
        yield return new WaitForSeconds(spawnTimer);
        if (_lm.canSpawn && !Physics.CheckBox(transform.position - checkCubePos, checkCubeExt, Quaternion.identity, 1 << LayerMask.NameToLayer("Enemy")))
        {
            currentGray = Instantiate(grayPrefab, transform.position - startPos, Quaternion.identity).GetComponent<Gray>();
            currentGray2 = Instantiate(grayPrefab, transform.position - startPos2, Quaternion.identity).GetComponent<Gray>();
            currentGray3 = Instantiate(grayPrefab, transform.position - startPos3, Quaternion.identity).GetComponent<Gray>();
            _lm.EnemySpawned();
            _lm.EnemySpawned();
            _lm.EnemySpawned();
            _lm.EnemySpawned();
            _lm.EnemySpawned();
            spawning = false;
            numberOfWaves ++;
            Debug.Log(numberOfWaves);
        }
        else StartCoroutine("SpawnGrey");
    }


    public void SpawnGreyLerp()
    {
        currentGray.SetPos(Vector3.Lerp(transform.position - startPos, transform.position - endPos, timer / timeLimit));

        timer += Time.deltaTime;
    }
    public void SpawnGreyLerpTwo()
    {
        currentGray.SetPos(Vector3.Lerp(transform.position - startPos, transform.position - endPos, timer / timeLimit));
        currentGray2.SetPos(Vector3.Lerp(transform.position - startPos2, transform.position - endPos2, timer / timeLimit));
        currentGray3.SetPos(Vector3.Lerp(transform.position - startPos3, transform.position - endPos3, timer / timeLimit));
        timer += Time.deltaTime;
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireCube(transform.position - checkCubePos, checkCubeExt);
        Gizmos.DrawWireCube(transform.position - startPos, new Vector3(0.5f, 0.5f, 0.5f));
        Gizmos.DrawWireCube(transform.position - endPos, new Vector3(0.5f, 0.5f, 0.5f));
    }
}
