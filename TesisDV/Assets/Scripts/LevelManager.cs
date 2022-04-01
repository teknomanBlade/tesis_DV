using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : MonoBehaviour
{
    public delegate void LevelDelegate();
    public event LevelDelegate OnStartRound;
    public event LevelDelegate OnEndRound;

    public BasicGray enemyPrefab;

    public List<Vector3> path;

    public List<EnemyBase> spawnedEnemies = new List<EnemyBase>();
    
    public int roundEnemies = 0;
    int maxEnemies = 24;
    int startingRound = 0;
    public int round = 0;
    public int winRound = 5;

    public int levelHealth = 10;

    public bool playing = true;
    public bool inRound = false;

    private void Start()
    {
        OnStartRound += StartRound;
        OnEndRound += EndRound;
        //BeginGame();
    }

    private void Update()
    {
        EndZone();
        if (round > winRound)
        {
            playing = false;
            WinGame();
        }
        if (playing && spawnedEnemies.Count == 0 && !inRound)
        {
            inRound = true;
            round++;
            BeginGame();
        }
    }

    public void BeginGame()
    {
        StartCoroutine("BeginGameCoroutine");
    }

    public void StartRound()
    {
        //roundEnemies = CalculateRoundEnemies();
        
        roundEnemies = 5;
        StartCoroutine("SpawnEnemies");
    }

    public void EndRound()
    {
        inRound = false;
    }

    public int CalculateRoundEnemies()
    {

        roundEnemies = roundEnemies + round;
        if (roundEnemies >= maxEnemies) return maxEnemies;
        return roundEnemies;
    }

    public void WinGame()
    {
        Debug.Log("You Win!");
    }

    public void LoseGame()
    {
        playing = false;
        Debug.Log("Loser");
    }

    IEnumerator BeginGameCoroutine()
    {
        yield return new WaitForSeconds(3f);
        OnStartRound?.Invoke();
    }

    IEnumerator SpawnEnemies()
    {
        spawnedEnemies.Add(Instantiate(enemyPrefab, path[0] + new Vector3(0f, 2f, 0f), Quaternion.identity));
        roundEnemies--;
        yield return new WaitForSeconds(1f);
        if (roundEnemies > 0) StartCoroutine("SpawnEnemies");
    }

    public Vector3 GetNextPos(int index)
    {
        if (index > path.Count - 1) return default(Vector3);
        else return path[index];
    }

    public void EndZone()
    {
        Collider[] cols = Physics.OverlapBox(path[path.Count - 1], new Vector3(2f, 2f, 2f), Quaternion.identity, GameVars.Values.GetEnemyLayerMask());
        if (cols.Length != 0)
        {
            foreach (Collider col in cols)
            {
                col.GetComponent<EnemyBase>().Die();
                levelHealth--;
                if (levelHealth < 1) LoseGame();
            }
            if (spawnedEnemies.Count == 0) EndRound();
        }
    }
}
